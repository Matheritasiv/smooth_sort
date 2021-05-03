(random-seed (time-nanosecond (current-time)))
(load-shared-object "./libsort.so")
(define smooth-sort
  (foreign-procedure "smooth_sort"
     ((* integer-64) unsigned-64) void))

(let* ([n 1000000] [r (expt 2 64)] [c (floor (/ r 2))] [t #f]
       [arr (foreign-alloc (* 8 n))]
       [parr (make-ftype-pointer integer-64 arr)])
  (let loop ([i (* 8 (1- n))])
    (unless (negative? i)
      (foreign-set! 'integer-64 arr i (- (random r) c))
      (loop (- i 8))))
  (set! t (current-time))
  (smooth-sort parr n)
  (set! t (time-difference (current-time) t))
  (let* ([l (1+ (apply max (map (lambda (x) (string-length
                (format "~d" (foreign-ref 'integer-64 arr x))))
                (list 0 (* 8 (1- n))))))]
         [w 80] [fmt (format "~~~dd" l)])
    (let loop ([i 0] [j n] [c w])
      (unless (zero? j)
        (printf fmt (foreign-ref 'integer-64 arr i))
        (loop (+ i 8) (1- j)
          (let ([c (- c l)])
            (if (positive? c) c
              (begin (newline) w))))))
    (printf "~&"))
  (printf "Elapsed time: ~6$s~%"
          (+ (time-second t) (/ (time-nanosecond t) 1e9)))
  (foreign-free arr))
