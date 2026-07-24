using System.Collections.Concurrent;

public sealed class InMemoryQuotaLedger(
    QuotaLedgerOptions options,
    TimeProvider timeProvider) : IQuotaLedger
{
    private readonly ConcurrentDictionary<string, SubscriptionState> states = new();

    public async Task<ReservationResult> TryReserveAsync(
        string subscriptionId,
        long tokens,
        string model,
        CancellationToken cancellationToken)
    {
        var state = states.GetOrAdd(subscriptionId, _ => new SubscriptionState());
        await state.Lock.WaitAsync(cancellationToken);
        try
        {
            var now = timeProvider.GetUtcNow();
            var periodState = state.GetPeriod(QuotaPeriod.Monthly(now));
            state.ReleaseExpired(now);

            if (periodState.Used + periodState.Reserved + tokens > options.StrictTokenQuota)
            {
                return new ReservationResult(
                    false,
                    null,
                    periodState.Snapshot(subscriptionId, options.StrictTokenQuota, now));
            }

            var reservation = new QuotaReservation(
                subscriptionId,
                Guid.NewGuid().ToString("N"),
                tokens,
                periodState.Period,
                now.Add(options.ReservationTtl));
            periodState.Reservations.Add(
                reservation.ReservationId,
                new PendingReservation(reservation, model));
            periodState.Reserved += tokens;

            return new ReservationResult(
                true,
                reservation,
                periodState.Snapshot(subscriptionId, options.StrictTokenQuota, now));
        }
        finally
        {
            state.Lock.Release();
        }
    }

    public async Task<UsageSnapshot> CompleteAsync(
        QuotaReservation reservation,
        long actualTokens,
        long promptTokens,
        long completionTokens,
        string model,
        CancellationToken cancellationToken)
    {
        var state = states.GetOrAdd(
            reservation.SubscriptionId,
            _ => new SubscriptionState());
        await state.Lock.WaitAsync(cancellationToken);
        try
        {
            var now = timeProvider.GetUtcNow();
            state.ReleaseExpired(now);
            var periodState = state.FindPeriod(reservation.Period);

            if (periodState is null
                || !periodState.Reservations.TryGetValue(
                    reservation.ReservationId,
                    out var pending))
            {
                throw new InvalidOperationException("The quota reservation no longer exists.");
            }

            if (pending.Completed)
            {
                return periodState.Snapshot(
                    reservation.SubscriptionId,
                    options.StrictTokenQuota,
                    now);
            }

            periodState.Reserved -= reservation.ReservedTokens;
            periodState.Used += actualTokens;
            pending.Completed = true;
            pending.ActualTokens = actualTokens;
            pending.PromptTokens = promptTokens;
            pending.CompletionTokens = completionTokens;
            pending.Model = model;
            pending.CompletedAt = now;

            return periodState.Snapshot(
                reservation.SubscriptionId,
                options.StrictTokenQuota,
                now);
        }
        finally
        {
            state.Lock.Release();
        }
    }

    public async Task<UsageSnapshot> GetUsageAsync(
        string subscriptionId,
        CancellationToken cancellationToken)
    {
        var state = states.GetOrAdd(subscriptionId, _ => new SubscriptionState());
        await state.Lock.WaitAsync(cancellationToken);
        try
        {
            var now = timeProvider.GetUtcNow();
            state.ReleaseExpired(now);
            return state.GetPeriod(QuotaPeriod.Monthly(now))
                .Snapshot(subscriptionId, options.StrictTokenQuota, now);
        }
        finally
        {
            state.Lock.Release();
        }
    }

    private sealed class SubscriptionState
    {
        internal SemaphoreSlim Lock { get; } = new(1, 1);

        private Dictionary<string, PeriodState> Periods { get; } = [];

        internal PeriodState GetPeriod(QuotaPeriod period)
        {
            if (!Periods.TryGetValue(period.Key, out var state))
            {
                state = new PeriodState(period);
                Periods.Add(period.Key, state);
            }

            return state;
        }

        internal PeriodState? FindPeriod(QuotaPeriod period) =>
            Periods.GetValueOrDefault(period.Key);

        internal void ReleaseExpired(DateTimeOffset now)
        {
            foreach (var period in Periods.Values)
            {
                period.ReleaseExpired(now);
            }
        }
    }

    private sealed class PeriodState(QuotaPeriod period)
    {
        internal QuotaPeriod Period { get; } = period;

        internal long Used { get; set; }

        internal long Reserved { get; set; }

        internal Dictionary<string, PendingReservation> Reservations { get; } = [];

        internal void ReleaseExpired(DateTimeOffset now)
        {
            foreach (var pending in Reservations.Values.Where(item =>
                         !item.Completed && item.Reservation.ExpiresAt <= now))
            {
                pending.Completed = true;
                Reserved -= pending.Reservation.ReservedTokens;
                Used += pending.Reservation.ReservedTokens;
                pending.ActualTokens = pending.Reservation.ReservedTokens;
                pending.CompletedAt = now;
            }
        }

        internal UsageSnapshot Snapshot(
            string subscriptionId,
            long limit,
            DateTimeOffset now)
        {
            var history = Reservations.Values
                .Where(item => item.CompletedAt is not null)
                .GroupBy(item => new
                {
                    Day = DateOnly.FromDateTime(item.CompletedAt!.Value.UtcDateTime),
                    item.Model,
                })
                .Select(group => new UsageHistoryPoint(
                    group.Key.Day,
                    group.Key.Model,
                    group.Sum(item => item.PromptTokens),
                    group.Sum(item => item.CompletionTokens),
                    group.Sum(item => item.ActualTokens)))
                .OrderBy(item => item.Day)
                .ThenBy(item => item.Model, StringComparer.Ordinal)
                .ToArray();

            return new UsageSnapshot(
                "strict",
                subscriptionId,
                Period.Start,
                Period.End,
                limit,
                Used,
                Reserved,
                Math.Max(0, limit - Used - Reserved),
                now,
                "authoritative",
                history);
        }
    }

    private sealed class PendingReservation(
        QuotaReservation reservation,
        string model)
    {
        internal QuotaReservation Reservation { get; } = reservation;

        internal string Model { get; set; } = model;

        internal bool Completed { get; set; }

        internal long ActualTokens { get; set; }

        internal long PromptTokens { get; set; }

        internal long CompletionTokens { get; set; }

        internal DateTimeOffset? CompletedAt { get; set; }
    }
}
