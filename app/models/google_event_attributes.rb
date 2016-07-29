class GoogleEventAttributes
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def call
    if recurring?
      recurrence_events
    else
      [{ start_at: start_at, end_at: end_at }]
    end
  end

  def recurring?
    !!event.recurrence
  end

  # [ { start_at: Time, end_at: Time }, ... ]
  def recurrence_events
    str = event.recurrence.first.split("RRULE:")[-1]
    s = IceCube::Schedule.new(start_at)
    rule = IceCube::Rule.from_ical(str)
    s.add_recurrence_rule(rule)
    occurrences =
      if rule.occurrence_count.nil? || rule.until_time.nil?
        end_time = 1.year.since
        s.occurrences(end_time)
      else
        s.all_occurrences
      end
    occurrences.map(&:to_time).map do |start|
      { start_at: start, end_at: start + time_diff }
    end
  end

  private

  def start_at
    event.start.try(:date_time) || event.start.try(:date).try(:beginning_of_day)
  end

  def end_at
    event.end.try(:date_time) || event.end.try(:date).try(:end_of_day)
  end

  def time_diff
    return if start_at.nil? || end_at.nil?

    end_at - start_at
  end
end
