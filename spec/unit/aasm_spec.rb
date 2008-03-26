require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class Foo
  include AASM
  initial_state :open
  state :open
  state :closed

  event :close do
    transitions :to => :closed, :from => [:open]
  end

  event :null do
    transitions :to => :closed, :from => [:open], :guard => :always_false
  end

  def always_false
    false
  end
end

class Bar
  include AASM
  state :read
  state :ended
end


describe AASM, '- class level definitions' do
  it 'should define a class level initial_state() method on its including class' do
    Foo.should respond_to(:initial_state)
  end

  it 'should define a class level state() method on its including class' do
    Foo.should respond_to(:state)
  end

  it 'should define a class level event() method on its including class' do
    Foo.should respond_to(:event)
  end
end

describe AASM, '- instance level definitions' do
  before(:each) do
    @foo = Foo.new
  end

  it 'should define a state querying instance method on including class' do
    @foo.should respond_to(:open?)
  end

  it 'should define an event! inance method' do
    @foo.should respond_to(:close!)
  end
end

describe AASM, '- initial states' do
  before(:each) do
    @foo = Foo.new
    @bar = Bar.new
  end

  it 'should set the initial state' do
    @foo.current_state.should == :open
  end

  it '#open? should be initially true' do
    @foo.open?.should be_true
  end

  it '#closed? should be initially false' do
    @foo.closed?.should be_false
  end

  it 'should use the first state defined if no initial state is given' do
    @bar.current_state.should == :read
  end
end

describe AASM, '- event firing' do
  it 'should fire the Event' do
    foo = Foo.new

    Foo.events[:close].should_receive(:fire).with(foo)
    foo.close!
  end

  it 'should update the current state' do
    foo = Foo.new
    foo.close!

    foo.current_state.should == :closed
  end

  it 'should attempt to persist if write_state is defined' do
    foo = Foo.new
    
    def foo.write_state
    end

    foo.should_receive(:write_state)

    foo.close!
  end
end

describe AASM, '- persistence' do
  it 'should read the state if it has not been set and read_state is defined' do
    foo = Foo.new
    def foo.read_state
    end

    foo.should_receive(:read_state)

    foo.current_state
  end
end

describe AASM, '- getting events for a state' do
  it '#events_for_current_state should use current state' do
    foo = Foo.new
    foo.should_receive(:current_state)
    foo.events_for_current_state
  end

  it '#events_for_current_state should use events_for_state' do
    foo = Foo.new
    foo.stub!(:current_state).and_return(:foo)
    foo.should_receive(:events_for_state).with(:foo)
    foo.events_for_current_state
  end
end

describe AASM, '- event callbacks' do
  it 'should call event_fired if defined and successful' do
    foo = Foo.new
    def foo.event_fired(from, to)
    end

    foo.should_receive(:event_fired)

    foo.close!
  end

  it 'should call event_failed if defined and transition failed' do
    foo = Foo.new
    def foo.event_failed(event)
    end

    foo.should_receive(:event_failed)

    foo.null!
  end
end


