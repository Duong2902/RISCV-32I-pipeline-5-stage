# ======= Basic clock =======
# Nếu chạy ở 100 MHz: period = 10.000 ns
# (Đổi thành 8.000 nếu bạn dùng 125 MHz; 20.000 nếu 50 MHz)
create_clock -name sys_clk -period 10.000 [get_ports clk]

# Reset là async, bỏ khỏi timing
set_false_path -from [get_ports rst_n]

