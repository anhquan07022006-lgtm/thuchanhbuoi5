### A Pluto.jl notebook ###
# v0.20.0

# ╔═╡ 09102026-0000-4000-8000-000000000001
begin
    READ_DATA = true
    RUN_APP = true
    ROOT_DATA = joinpath(@__DIR__, "data")
end

# ╔═╡ 09102026-0000-4000-8000-000000000002
AppCore = let
    sandbox = Module(:ThucHanhNgay0910)
    Base.include(sandbox, joinpath(@__DIR__, "TH_2026_10_09_Sinh_vien.jl"))
    Base.invokelatest(getfield, sandbox, :GiaoDon)
end

# ╔═╡ 09102026-0000-4000-8000-000000000003
"""
1. Bài toán & dữ liệu: Đọc don_hang.csv và ban_do.csv từ data/MINI001 (3 đơn ID 1, 2, 3; 6 đỉnh; 7 cạnh; ngân sách B = 8).
2. Ý tưởng & chi phí 4 hàm:
- merge_sort(a, before): Chia đôi mảng, đệ quy sắp xếp hai nửa và trộn ổn định (ưu tiên nửa trái khi hòa). Thời gian O(n log n), bộ nhớ phụ O(n).
- binary_search(a, id): Thu hẹp đoạn [lo, hi] qua mid trên mảng Order có ID tăng dần. Thời gian O(log n), bộ nhớ phụ O(1).
- bfs_routes(graph, source=1): Duyệt BFS bằng CircularQueue, gán distance và parent ngay khi phát hiện đỉnh. Thời gian O(V + E), bộ nhớ cốt lõi O(V).
- knapsack(orders, costs, budget): Quy hoạch động ba lô 0/1 trên bảng (n+1)x(B+1), truy vết tập đơn tối ưu. Thời gian và bộ nhớ O(nB).
"""

# ╔═╡ 09102026-0000-4000-8000-000000000004
ho_so = AppCore.mini_profile()

# ╔═╡ 09102026-0000-4000-8000-000000000005
du_lieu = READ_DATA ? AppCore.read_data(joinpath(ROOT_DATA,"MINI001")) : nothing

# ╔═╡ 09102026-0000-4000-8000-000000000006
bao_cao = !RUN_APP || du_lieu === nothing ? nothing : let
    s = AppCore.build_session(du_lieu.orders,du_lieu.edges,ho_so)
    r = AppCore.plan!(s)
    trace = NamedTuple[]
    save(label) = push!(trace,(buoc=label,queue=AppCore.queue_values(s.pending),
                              stack=copy(s.completed),spent=s.spent,earned=s.earned))
    save("Sau lập kế hoạch")
    AppCore.deliver!(s); save("Sau giao một đơn")
    AppCore.undo!(s); save("Sau hoàn tác")
    while s.pending.count > 0
        AppCore.deliver!(s)
    end
    save("Sau giao hết")
    (chi_phi=copy(s.costs),tuyen=deepcopy(s.routes),chon=copy(s.selected_ids),
     loi_ich_toi_uu=r.optimal.value,truy_vet=trace,bat_bien=AppCore.check_invariants(s))
end

# ╔═╡ 09102026-0000-4000-8000-000000000007
"""
Giải thích ô F(2,8) và vị trí table[i+1,b+1] trong Julia:
- Ô F(2,8) nằm tại table[3,9] (xét 2 đơn đầu với ngân sách b = 8, đơn 2 có chi phí 5, lợi ích 8).
- Phương án không lấy đơn 2: F(1,8) = table[2,9] = 6.
- Phương án lấy đơn 2: 8 + F(1, 8-5) = 8 + table[2,4] = 8 + 6 = 14.
- Chọn max(6, 14) = 14. Nhánh chọn lấy từ hàng i-1 để mỗi đơn chỉ được lấy tối đa 1 lần. Kết quả khớp với vét cạn (value = 14, chọn đơn [1, 2]).
"""

# ╔═╡ 09102026-0000-4000-8000-000000000008
"""
Minh chứng nộp (Bùi Anh Quân - MSSV: N24DCDT075):
- Đã hoàn thiện 4 hàm trong TH_2026_10_09_Sinh_vien.jl.
- Kiểm thử: julia TH_2026_10_09_Kiem_thu.jl --phase=all đạt toàn bộ các pha (data, sort, search, bfs, dp, app).
- Đã xuất CSV kết quả tại data/MINI001/ket_qua.csv và data/N24DCDT075/ket_qua.csv.
"""

# ╔═╡ 09102026-0000-4000-8000-000000000009
if RUN_APP && bao_cao !== nothing
    println("Kết quả từ cùng lõi ứng dụng Julia:")
    show(stdout, "text/plain", bao_cao)
    println()
end

# ╔═╡ Cell order:
# ╠═09102026-0000-4000-8000-000000000001
# ╠═09102026-0000-4000-8000-000000000002
# ╠═09102026-0000-4000-8000-000000000003
# ╠═09102026-0000-4000-8000-000000000004
# ╠═09102026-0000-4000-8000-000000000005
# ╠═09102026-0000-4000-8000-000000000006
# ╠═09102026-0000-4000-8000-000000000007
# ╠═09102026-0000-4000-8000-000000000008
# ╠═09102026-0000-4000-8000-000000000009