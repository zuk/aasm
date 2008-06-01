# Hash out syntax for supporting multiple state machines

class Foo
  aasm :machine1 do
    state :foo
    state :bar

    event :doit do
      transitions :to => :bar, :from => [:foo]
    end
  end

  aasm :machine2 do
    state :x
    state :y

    event :forkme do
      transitions :to => :y, :from => [:x]
    end
  end
end

foo = Foo.new

# Firing events
foo.machine1.doit!

foo.machine2.forkme!

# Querying states
foo.machine1.current_state
foo.machine1.foo?

foo.machine2.current_state
foo.machine2.x?
