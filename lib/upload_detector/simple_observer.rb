module SimpleObserver

  module Observable
    def add_listener listener
      (@listeners ||= []) << listener
    end

    def notify_listeners event_name, *args
      @listeners && @listeners.each do |listener|
        if listener.respond_to? event_name
          listener.public_send event_name, *args
        end
      end
    end
  end
end

