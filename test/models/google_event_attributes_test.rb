require "test_helper"

class GoogleEventAttributesTest < ActiveSupport::TestCase
  class DummyGoogleEvent
    class DummyDate
      def initialize(raw)
        @raw = raw
      end

      def date_time
        return if !@raw.is_a?(DateTime) && !@raw.is_a?(Time)
        @raw
      end

      def date
        return unless @raw.is_a?(Date)
        @raw
      end
    end

    attr_reader :start, :end

    def initialize(start_at, end_at, recurrence_str = nil)
      @start = DummyDate.new(start_at)
      @end = DummyDate.new(end_at)
      @recurrence_str = recurrence_str
    end

    def recurrence
      return unless @recurrence_str

      [@recurrence_str]
    end
  end

  test "#call with not-recurring event" do
    attrs = attributes(event_obj)
    assert_equal [{ start_at: Time.new(2016, 7, 15, 10), end_at: Time.new(2016, 7, 15, 12) }], attrs.call
  end

  test "#call with recurring event" do
    attrs = attributes(event_obj(recurrence: "RRULE:FREQ=WEEKLY;UNTIL=20160802T190000Z;BYDAY=WE"))
    expected = [
      { start_at: Time.new(2016, 7, 20, 10), end_at: Time.new(2016, 7, 20, 12) },
      { start_at: Time.new(2016, 7, 27, 10), end_at: Time.new(2016, 7, 27, 12) },
    ]
    assert_equal expected, attrs.call
  end

  test "#recurring? with recurring event" do
    attrs = attributes(event_obj(recurrence: "RRULE:FREQ=WEEKLY;UNTIL=20160802T190000Z;BYDAY=WE"))
    assert attrs.recurring?
  end

  test "#recurring? without recurring event" do
    attrs = attributes(event_obj)
    refute attrs.recurring?
  end

  test "#recurrence_events with not-recurring event" do
    attrs = attributes(event_obj)
    assert_raises(NoMethodError) { attrs.recurrence_events }
  end

  test "#recurrence_events with recurring event(with single day event)" do
    attrs = attributes(event_obj(recurrence: "RRULE:FREQ=WEEKLY;UNTIL=20160802T190000Z;BYDAY=WE"))
    expected = [
      { start_at: Time.new(2016, 7, 20, 10), end_at: Time.new(2016, 7, 20, 12) },
      { start_at: Time.new(2016, 7, 27, 10), end_at: Time.new(2016, 7, 27, 12) },
    ]
    assert_equal expected, attrs.recurrence_events
  end

  private

  def attributes(event)
    GoogleEventAttributes.new(event)
  end

  def event_obj(start_at: Time.new(2016, 7, 15, 10), end_at: Time.new(2016, 7, 15, 12), recurrence: nil)
    DummyGoogleEvent.new(start_at, end_at, recurrence)
  end
end
