    .text
    .globl _start

# Quy ước:
# x5 = base (0), x6 = n (=5), x10=i, x11=last=n-1, x12=j
# x15=tmp addr, x16=arr[j], x17=arr[j+1]

_start:
    addi x5,  x0, 0          # base = 0
    addi x6,  x0, 5          # n = 5
    addi x10, x0, 0          # i = 0
    addi x11, x6, -1         # last = n-1

 L_outer_check:
    bge  x10, x11, done   # i >= n-1 ?
    addi x12, x0, 0          # j = 0

 L_inner_check:
    add  x14, x10, x12       # t = i + j
    blt  x14, x11, L_inner   # nếu i+j < n-1 → còn cặp để so sánh
    jal  x0,  L_next_i

 L_inner:
    slli x15, x12, 2         # offset = j*4
    add  x15, x5,  x15       # &arr[j]
    lw   x16, 0(x15)         # a = arr[j]
    lw   x17, 4(x15)         # b = arr[j+1]
    bge  x17, x16, L_no_swap # nếu b >= a → không đổi
    sw   x17, 0(x15)         # swap a,b
    sw   x16, 4(x15)
L_no_swap:
    addi x12, x12, 1         # j++
    jal  x0,  L_inner_check

L_next_i:
    addi x10, x10, 1         # i++
    jal  x0,  L_outer_check  # quay lại kiểm i<n-1

done:
    jal  x0,  done           # vòng lặp vô hạn
