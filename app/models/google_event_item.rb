class GoogleEventItem
  attr_reader :item

  def initialize(event_item)
    @item = event_item
  end

  # TODO
  def load_proper_event_item
    case
    when item.status == "canceled"
      # use id only
      GoogleEvent::CanceledEvent.new(item)
    when item.recurrence
      GoogleEvent::RecurringEvent.new(item)
    when item.start.try(:date)
      GoogleEvent::AllDayEvent.new(item)
    when item.start.try(:date_time)
      GoogleEvent::AllDayEvent.new(item)
    else
      GoogleEvent::UnknownEvent.new(item)
    end
  end
end
