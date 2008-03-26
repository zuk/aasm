require File.join(File.dirname(__FILE__), 'event')
require File.join(File.dirname(__FILE__), 'state')
require File.join(File.dirname(__FILE__), 'persistence')

module AASM
  class InvalidTransition < Exception
  end
  
  def self.included(base) #:nodoc:
    base.extend AASM::ClassMethods
    AASM::Persistence.set_persistence(base)
  end

  module ClassMethods
    def initial_state(set_state=nil)
      if set_state
        initial_state = set_state
      else
        @initial_state
      end
    end
    
    def initial_state=(state)
      @initial_state = state
    end
    
    def state(name, options={})
      states << name unless states.include?(name)
      self.initial_state = name unless self.initial_state

      define_method("#{name.to_s}?") do
        current_state == name
      end
    end
    
    def event(name, &block)
      unless events.has_key?(name)
        events[name] = AASM::SupportingClasses::Event.new(name, &block)
      end

      define_method("#{name.to_s}!") do
        new_state = self.class.events[name].fire(self)
        unless new_state.nil?
          if self.respond_to?(:event_fired)
            self.event_fired(self.current_state, new_state)
          end
          
          self.current_state = new_state
          true
        else
          if self.respond_to?(:event_failed)
            self.event_failed(name)
          end
          
          false
        end
      end
    end

    def states
      @states ||= []
    end

    def events
      @events ||= {}
    end
  end

  # Instance methods
  def current_state
    return @current_state if @current_state

    if self.respond_to?(:read_state) || self.private_methods.include?('read_state')
      @current_state = read_state
    end
    return @current_state if @current_state
    self.class.initial_state
  end

  def events_for_current_state
    events_for_state(current_state)
  end

  def events_for_state(state)
    events = self.class.events.values.select {|event| event.transitions_from_state?(state) }
    events.map {|event| event.name}
  end

  private
  def current_state=(state)
    @current_state = state
    if self.respond_to?(:write_state) || self.private_methods.include?('write_state')
      write_state(state)
    end
  end
end
