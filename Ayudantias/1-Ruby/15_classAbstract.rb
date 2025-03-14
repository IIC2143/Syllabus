module Animal
    attr_accessor :name, :owner # Try commentig this
    def initialize name, owner
        @name = name
        @owner = owner
        @steps = 0
    end
    # esto seria un metodo abstracto
    def talk
        raise NotImplementedError, "#{self.class} debe implementar el método 'speak'"
      end
    
      # Otro método que podría ser común a todas las clases que incluyan este módulo
    def move
        puts "#{self.class} se está moviendo"
    end

    def to_s
        puts "I am #{@name} and my owner is #{@owner}"
    end

end


class Cat
include Animal
    attr_accessor :purrs
    def initialize(name, owner, purrs)
        super(name, owner)
        @purrs = purrs
    end

    def talk
        miau = "MI" + ("A" * rand(1..10)) + "U"
        puts miau
    end

    def pet
        @purrs += 10
        puts "Purr"
    end

end

class Chicken
    include Animal
        def initialize(name, owner)
            super(name, owner)
        end
    
        def talk
            cocoroco = "CO" + ("CORO" * rand(1..10)) + "CO"
            puts cocoroco
        end

    
    
    end

# si intentas correr como antes solo animal este te enviara un error debido a que es abstracto
#random_animal = Animal.new("Steve", "Notch")



cat = Cat.new("Grogu", "Pedro", 0)
chicken = Chicken.new("KFC", "Coronel Sanders")
chicken.talk
puts chicken.move
chicken.to_s

cat.talk

3.times do |_|
    cat.pet
end

puts cat.purrs
puts cat.move
cat.to_s
