.intel_syntax noprefix
.global main

fibonacci:
        push    rbp                          # Зберігаємо попередній вказівник кадру
        mov     rbp, rsp                     # Встановлюємо новий вказівник кадру
        push    rbx                          # Зберігаємо rbx
        sub     rsp, 24                      # Виділяємо 24 байти на стеку для локальних змінних
        mov     DWORD PTR [rbp-20], edi      # Зберігаємо вхідний аргумент (n) із EDI на стек
        
        # Базові випадки
        cmp     DWORD PTR [rbp-20], 0        # Порівнюємо n з 0
        jne     .L2                          # Якщо n != 0, переходимо до наступної перевірки (.L2)
        mov     eax, 0                       # Якщо n == 0, записуємо результат 0 у регістр eax
        jmp     .L3                          # Переходимо до виходу з функції
.L2:
        cmp     DWORD PTR [rbp-20], 1        # Порівнюємо n з 1
        jne     .L4                          # Якщо n != 1, переходимо до рекурсії (.L4)
        mov     eax, 1                       # Якщо n == 1, записуємо результат 1 у регістр eax
        jmp     .L3                          # Переходимо до виходу з функції

# Рекурсивний випадок
.L4:
        mov     eax, DWORD PTR [rbp-20]      # Завантажуємо поточне значення n в eax
        sub     eax, 1                       # Обчислюємо n - 1
        mov     edi, eax                     # Передаємо (n - 1) як перший аргумент у EDI
        call    fibonacci                    # Рекурсивний виклик: fibonacci(n - 1)
        mov     rbx, rax                     # Зберігаємо отриманий результат у rbx
        
        mov     eax, DWORD PTR [rbp-20]      # Знову завантажуємо оригінальне n в eax
        sub     eax, 2                       # Обчислюємо n - 2
        mov     edi, eax                     # Передаємо (n - 2) як перший аргумент у EDI
        call    fibonacci                    # Рекурсивний виклик: fibonacci(n - 2)
        add     rax, rbx                     # Додаємо результат

# Вихід із функції
.L3:
        mov     rbx, QWORD PTR [rbp-8]       # Відновлюємо оригінальне значення rbx зі стеку
        leave                                # Очищаємо стек
        ret                                  # Повернення з функції

# Дані для читання
.LC0:
        .string "Enter the Fibonacci number you want to calculate (0-93): "
.LC1:
        .string "%d"
.LC2:
        .string "Please enter a number between 0 and 93."
.LC3:
        .string "The %dth Fibonacci number is %llu\n"

# Головна частина main
main:
        push    rbp                          # Стандартний пролог функції
        mov     rbp, rsp
        sub     rsp, 16                      # Виділяємо 16 байтів для локальних змінних
        mov     edi, OFFSET FLAT:.LC0        # Завантажуємо адресу рядка з підказкою
        mov     eax, 0                       # 0 вказує printf, що векторні регістри не використовуються
        call    printf
        lea     rax, [rbp-4]                 # Отримуємо адресу локальної змінної на стеку
        mov     rsi, rax                     # Передаємо цю адресу як другий аргумент у rsi
        mov     edi, OFFSET FLAT:.LC1        # Передаємо рядок формату "%d" у edi
        mov     eax, 0
        call    __isoc23_scanf               # Викликаємо scanf
        mov     eax, DWORD PTR [rbp-4]       # Завантажуємо зчитане число в eax
        test    eax, eax                     # Перевіряємо знак числа
        js      .L6                          # Якщо число від'ємне, йдемо на помилку
        mov     eax, DWORD PTR [rbp-4]       # Знову завантажуємо число
        cmp     eax, 93                      # Порівнюємо його з 93
        jle     .L7                          # Якщо число <= 93, воно коректне то переходимо до обчислень
.L6:
        mov     edi, OFFSET FLAT:.LC2        # Завантажуємо рядкок помилки про діапазон 0-93
        call    puts                         # Виводимо його через puts
        mov     eax, 1                       # Встановлюємо код повернення програми = 1
        jmp     .L9                          # Йдемо на вихід

# Обчислення числа Фібоначчі
.L7:
        mov     eax, DWORD PTR [rbp-4]       # Завантажуємо валідне число
        mov     edi, eax                     # Передаємо його як аргумент у edi
        call    fibonacci                    # Викликаємо нашу функцію обчислення
        
        # Виведення результату
        mov     rdx, rax                     # Результат Фібоначчі передаємо у rdx
        mov     eax, DWORD PTR [rbp-4]       # Початкове введене число передаємо у esi
        mov     esi, eax
        mov     edi, OFFSET FLAT:.LC3        # Завантажуємо фінальний шаблон рядка виведення
        mov     eax, 0
        call    printf                       # Виводимо результат
        mov     eax, 0                       # Встановлюємо успішний код повернення програми = 0

# Завершення програми
.L9:
        leave                                # Очищаємо фрейм стеку
        ret                                  # Вихід із програми

.section .note.GNU-stack,"",@progbits
