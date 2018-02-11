def input(string="Enter string")
 puts string
 enteredText = gets.chomp
 return enteredText
end

def print(string="")
  puts(string)
end

print("Hello World")



x=3

name="Bob"



y=String(3*27)

Integer("3")

Float("3.14")



print(x)

print(y)

print(name)



def triple(number)

    return number*3

end



y=triple(7)

print(y)




array names[5]

names[0]=”Ahmad”

names[1]=”Ben”

names[2]=”Catherine”

names[3]=”Dana”

names[4]=”Elijah”

print(names[3])



entry=input("Please enter your name")



if entry=="Harsh" 

    print("You selected Harsh") 
elsif entry=="B" 

    print("You selected B")

else

    print("Unrecognised selection")

end




def greeting(name)

    print("anyway, hello "+name)

end



greeting(entry)



someText="Computer Science"

print(someText.length)

print(someText.slice(3,3))




for i in 0..7

    print(i)

end


while true

    answer=input("What is the answer to life, the universe and everything?")

    break if  answer=="42"

end


while (x % 10 <= 5)

    print(x)

    x = x + 1

end



print()



print("Counting from given input to 0")



def countDownFrom(number)

    while(number > 0)

        print(number)

        number = number - 1

    end

end









countDownAmount = 20

countDownFrom(countDownAmount)



print()



something = input("Enter anything")

case something

    when "A"

         print("You picked A")

    when "42"

         print("#Douglas Adams")

    else

         print("You are a slave to the system")

end