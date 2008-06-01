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
foo.machine1.doit!
foo.machine2.forkme!
