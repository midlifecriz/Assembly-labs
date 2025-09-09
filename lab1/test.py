print("Введите числа a, b, c, d, e через пробел: ")
a, b, c, d, e = map(int, input().split())
result = a*c//b + d*b//e - c**2//(a*d)
print(a*c//b, "  ", d*b//e, "  ", c**2//(a*d))
print("Result:", result)


