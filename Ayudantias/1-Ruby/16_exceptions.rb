#Raise error
begin ## Equivalent to try on python
    puts "this will be shown"
    raise "an error"
    puts "this won't be shown"

rescue => error ## Except on python (you can also catch specific errors)
    puts error.message # "an error"
end

#Built-in exceptions 
begin
    # Divide by zero to raise an exception
    result = 10 / 0
  rescue ZeroDivisionError => e
    puts "An error occurred: #{e.message}"
  end

# after running
# this will be shown
# an error
# An error occurred: divided by 0
