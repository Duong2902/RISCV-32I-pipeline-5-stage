.data
# Ma trận A (2x3)
A:  .word 1, 2, 3
    .word 4, 5, 6

# Ma trận B (2x3)
B:  .word 7, 8, 9
    .word 10, 11, 12

# Ma trận C (2x3) chưa có dữ liệu
C:  .space 24      # 6 phần tử * 4 byte

    .text
    .globl main
    .globl mat_add

# Hàm cộng hai ma trận
# Tham số:
# a0 = &A[0], a1 = &B[0], a2 = &C[0], a3 = m, a4 = n
mat_add:
    addi    t5, x0, 0x55
    add     t0, x0, a3        # t0 = m (số hàng)

row_loop:
    beq     t0, x0, done      # nếu m == 0 -> kết thúc
    add     t1, x0, a4        # t1 = n (số cột)

col_loop:
    beq     t1, x0, next_row  # nếu n == 0 -> sang hàng tiếp theo
    lw      t2, 0(a0)         # t2 = A[i]
    lw      t3, 0(a1)         # t3 = B[i]
    add     t2, t2, t3        # t2 = A[i] + B[i]
    sw      t2, 0(a2)         # C[i] = t2
    addi    a0, a0, 4         # ++ptr A
    addi    a1, a1, 4         # ++ptr B
    addi    a2, a2, 4         # ++ptr C
    addi    t1, t1, -1        # giảm số cột
    bne     t1, x0, col_loop

next_row:
    addi    t0, t0, -1        # giảm số hàng
    bne     t0, x0, row_loop

done:
    ret

# Hàm main
main:
    la   a0, A
    la   a1, B
    la   a2, C
    li   a3, 2          # m = 2 hàng
    li   a4, 3          # n = 3 cột
    jal  ra, mat_add
    
    la   t6, C
    lw   t0, 0(t6)      # kỳ vọng 8
    lw   t1, 4(t6)      # 10
    lw   t2, 8(t6)      # 12
    lw   t3, 12(t6)     # 14
    lw   t4, 16(t6)     # 16
    lw   t5, 20(t6)     # 18
    # Thoát (Linux syscall exit)
    li   a7, 10         # sys_exit
    li   a0, 0
    ecall