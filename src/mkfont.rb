# encoding: utf-8
def count_astarisk str
    num = 0
    digit = 2**7
    8.times do |i|
        if str[i] == '*'
            num += digit
        end
        digit /= 2
    end
    num
end

def print_gas num
    #puts ".byte 0x#{num.to_s(16)}"
    print "0x#{num.to_s(16)}, "
end
File.open('hankaku.txt',"r:utf-8" ) do |f|
    while line  = f.gets
        if line.include?("char")
            puts "\n"
            16.times{
                line = f.gets
                num = count_astarisk line
                print_gas num
            }
        end
    end
end

