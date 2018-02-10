def input(string="Enter string")
 puts string
 enteredText = gets.chomp
 return enteredText
end

def print(string="")
  puts(string)
end

x=3

name="Bob"



y=(3*27).to_s

("3").to_i
("3.14").to_f


print(x)

print(y)



def triple(number)

    return number*3

end



y=triple(7)

print(y)



# Procedures are pretty similar to defs tbh

def greeting(name)

    print("hello"+name)

end



greeting("Hamish")



someText="Computer Science"

print(someText.length)

print(someText.slice(3,3))



# For loops might be tricky

for i in 0..7

    print(i)

end


while true

    answer=input("What is the answer to life, the universe and everything?")

    break if  answer=="42"

end


print("hello")

entry=input("Please enter your name")



if entry=="Harsh" 

    print("You selected Harsh") # That's me

elsif entry=="B" 

    print("You selected B")

else

    print("Unrecognised selection")

end



while (x % 10 <= 5)

    print(x)

    x = x + 1

end



print()



print("Counting while truewn from given input to 0")



def countDownFrom(number)

    while(number > 0)

        print(number)

        number = number - 1

    end

end



# Below line is not working

#countDownAmount = (input).to_inter that number"))

countDownAmount = 20

countDownFrom(countDownAmount)