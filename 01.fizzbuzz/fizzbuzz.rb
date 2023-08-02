def fizzbuzz(first, last)
  x = last - first + 1
  n = first
  x.times do
  if n % 15 == 0
    puts "FizzBuzz"
  elsif n % 3 == 0
    puts "Fizz"
  elsif n % 5 == 0
    puts "Buzz"
  else
    puts "#{n}"
  end
    n += 1
  end
end

fizzbuzz(1,20)
