(* ****** ****** *)
//
// LG 2018-04-03
//
(* ****** ****** *)

extern
fun
print_line(out: FILEref, n: int): void

extern
fun
print_blank(out: FILEref, n: int): void

extern
fun
print_centered(out: FILEref, s: string, n: int): void

extern
fun
print_centered_transact(out: FILEref, t: transaction, n: int): void

extern
fun
print_data(xs: list0(transaction), n: int, col: int): void

extern
fun
print_centered_contract(out: FILEref, c: contract, n: int): void

extern
fun
print_centered_state(out: FILEref, s: statement, n: int): void

extern
fun
print_result(xs: result, n: int, col: int): void

extern
fun
print_queries(xs: queries, n: int, col: int): void

(* ****** ****** *)

extern
fun
print_block(b0: block): void // stdout
and
prerr_block(b0: block): void // stderr

extern
fun
fprint_block(out: FILEref, b0: block): void

(* ****** ****** *)

overload print with print_block
overload prerr with prerr_block
overload fprint with fprint_block

(* ****** ****** *)

implement
print_block(b0) =
fprint_block(stdout_ref, b0)
implement
prerr_block(b0) =
fprint_block(stderr_ref, b0)

(* ****** ****** *)

implement
fprint_block(out, b0) = let

  val head = b0.0
  val currh = b0.1
  val tstamp = b0.2
  
  val block_num = "block #0" + int2str(head.0)
  val nounce = int2str(head.1)
  val data = head.2
  val res = head.3
  val qry = head.4
  val prevh = head.5
  
  val max = list0_foldleft<int>(qry, 0, lam(res, x) => let val m = 10 + list0_length(string_explode(x.0)) + list0_length(string_explode(x.1)) + list0_length(string_explode(int2str(x.2))) in if m > res then m else res end)
  
  val col = 17
  val r = (if max > 70 then max else 70) : int
  val row = r + col
in
(
  print_line(out, row);
  fprint!(out, "|");
  print_centered(out, block_num, row - 2);
  fprint!(out, "|\n");
  
  print_line(out, row);
  fprint!(out, "|");
  print_centered(out, "TimeStamp", col);
  fprint!(out, "|");
  print_centered(out, tstamp, row - col - 3);
  fprint!(out, "|\n");
  
  print_line(out, row);
  fprint!(out, "|");
  print_centered(out, "Nonce", col);
  fprint!(out, "|");
  print_centered(out, nounce, row - col - 3);
  fprint!(out, "|\n");

  print_line(out, row);
  print_data(data, row - col - 3, col);
  
  print_line(out, row);
  print_result(res, row - col - 3, col);
  
  print_line(out, row);
  print_queries(qry, row - col - 3, col);
  
  print_line(out, row);
  fprint!(out, "|");
  print_centered(out, "Previous Hash", col);
  fprint!(out, "|");
  print_centered(out, prevh, row - col - 3);
  fprint!(out, "|\n");
  
  print_line(out, row);
  fprint!(out, "|");
  print_centered(out, "Hash", col);
  fprint!(out, "|");
  print_centered(out, currh, row - col - 3);
  fprint!(out, "|\n");

  print_line(out, row);
)
end

(* ****** ****** *)

implement
print_blank(out, n) =
if n = 0 then fprint!(out, "")
else (fprint!(out, " "); print_blank(out, n - 1))

implement
print_line(out, n) =
if n = 0 then fprint!(out, "\n")
else (fprint!(out, fg(reset(), BLUE), "-", reset()); print_line(out, n - 1))

implement
print_centered(out, s, n) = let
  val len = list0_length(string_explode(s))
  val lpad = (n - len) / 2
  val rpad = n - len - lpad
in
  (
    print_blank(out, lpad);
    (
      if list0_length(string_explode(s)) = 64
      then fprint!(out, fg(reset(), YELLOW), s, reset())
      else 
      ( 
        let 
          val xs = parse_args(s)
        in
          case+ xs of
          | nil0() => fprint!(out, s)
          | cons0(x, xs) => 
              if x = "block"
              then fprint!(out, fg(reset(), GREEN), s, reset())
              else fprint!(out, s)
        end
      )
    );
    print_blank(out, rpad)
  )
end

(* ****** ****** *)

extern
fun
print_chain(ch: chain): void

extern
fun
print_arrow(): void

implement
print_arrow() =
(
  fprint!(stdout_ref, "|||");
  fprint!(stdout_ref, '\n');
  fprint!(stdout_ref, "|||");
  fprint!(stdout_ref, '\n');
  fprint!(stdout_ref, '\n');
)

implement
print_chain(ch) = 
case+ ch of
| nil0() => println!()
| cons0(_, _) => let
  val-cons0(b, ch) = list0_reverse(ch)
  val () = (list0_reverse(ch)).foreach()(lam(b) => (println!(b); print_arrow()))
  val () = println!(b)
in
  ()
end


implement
print_data(xs, n, col) = let
  val N = list0_length(xs)
  val padup = (N - 1) / 2
  val paddown = N - 1 - padup

  fun aux(xs: list0(transaction), padup: int, paddown: int): void =
    case+ xs of
    | nil0() => ()
    | cons0(x, xs) =>
          if padup = 0 
          then (
            fprint!(stdout_ref, "|");
            print_centered(stdout_ref, "Transactions", col);
            fprint!(stdout_ref, "|");
            print_centered_transact(stdout_ref, x, n);
            fprint!(stdout_ref, "|\n");
            aux(xs, padup - 1, paddown - 1)
          )
          else
          (
            if padup < 0 
            then 
            (
              fprint!(stdout_ref, "|");
              print_centered(stdout_ref, "", col);
              fprint!(stdout_ref, "|");
              print_centered_transact(stdout_ref, x, n);
              fprint!(stdout_ref, "|\n");
              aux(xs, padup - 1, paddown - 1)
            )
            else 
            (
              fprint!(stdout_ref, "|");
              print_centered(stdout_ref, "", col);
              fprint!(stdout_ref, "|");
              print_centered_transact(stdout_ref, x, n);
              fprint!(stdout_ref, "|\n");
              aux(xs, padup - 1, paddown)
            )
          )
in
  aux(xs, padup, paddown)
end


implement
print_centered_transact(out, t, n) = let
  val from = t.0
  val to = t.1
  val amount = t.2
in
  print_centered(out, from + " sent $" + int2str(amount) + " to " + to, n)
end


implement
print_result(xs, n, col) = let
  val N = list0_length(xs)
  val padup = (N - 1) / 2
  val paddown = N - 1 - padup

  fun aux(xs: result, padup: int, paddown: int): void =
    case+ xs of
    | nil0() => ()
    | cons0(x, xs) =>
          if padup = 0 
          then (
            fprint!(stdout_ref, "|");
            print_centered(stdout_ref, "Code Results", col);
            fprint!(stdout_ref, "|");
            print_centered_contract(stdout_ref, x, n);
            fprint!(stdout_ref, "|\n");
            aux(xs, padup - 1, paddown - 1)
          )
          else
          (
            if padup < 0 
            then 
            (
              fprint!(stdout_ref, "|");
              print_centered(stdout_ref, "", col);
              fprint!(stdout_ref, "|");
              print_centered_contract(stdout_ref, x, n);
              fprint!(stdout_ref, "|\n");
              aux(xs, padup - 1, paddown - 1)
            )
            else 
            (
              fprint!(stdout_ref, "|");
              print_centered(stdout_ref, "", col);
              fprint!(stdout_ref, "|");
              print_centered_contract(stdout_ref, x, n);
              fprint!(stdout_ref, "|\n");
              aux(xs, padup - 1, paddown)
            )
          )
in
  aux(xs, padup, paddown)
end


implement
print_centered_contract(out, c, n) = let
  val id = c.0
  val v = c.1
  val g = c.2
in
  print_centered(out, "id: "+ id +", result: " + v + ", gas = " + int2str(g), n)
end


implement
print_queries(xs, n, col) = let
  val N = list0_length(xs)
  val padup = (N - 1) / 2
  val paddown = N - 1 - padup

  fun aux(xs: queries, padup: int, paddown: int): void =
    case+ xs of
    | nil0() => ()
    | cons0(x, xs) =>
          if padup = 0 
          then (
            fprint!(stdout_ref, "|");
            print_centered(stdout_ref, "Queries", col);
            fprint!(stdout_ref, "|");
            print_centered_state(stdout_ref, x, n);
            fprint!(stdout_ref, "|\n");
            aux(xs, padup - 1, paddown - 1)
          )
          else
          (
            if padup < 0 
            then 
            (
              fprint!(stdout_ref, "|");
              print_centered(stdout_ref, "", col);
              fprint!(stdout_ref, "|");
              print_centered_state(stdout_ref, x, n);
              fprint!(stdout_ref, "|\n");
              aux(xs, padup - 1, paddown - 1)
            )
            else 
            (
              fprint!(stdout_ref, "|");
              print_centered(stdout_ref, "", col);
              fprint!(stdout_ref, "|");
              print_centered_state(stdout_ref, x, n);
              fprint!(stdout_ref, "|\n");
              aux(xs, padup - 1, paddown)
            )
          )
in
  aux(xs, padup, paddown)
end

implement
print_centered_state(out, s, n) = let
  val q = s.0
  val v = s.1
  val g = s.2
  val qs = string_explode(q)
in
  if qs[0] = 'S' andalso qs[1] = 'E'
  then print_centered(out, "SELECT QUERY output: " + v + " | GAS = " + int2str(g), n)
  else print_centered(out, q + " | GAS = " + int2str(g), n)
end


(* ****** ****** *)

(* end of [print_ops.dats] *)