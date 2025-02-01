;; Guild Treasury Contract

;; Constants
(define-constant err-insufficient-funds (err u200))
(define-constant err-unauthorized (err u201))

;; Data structures
(define-map guild-treasury
  { guild-id: uint }
  {
    balance: uint,
    last-updated: uint
  }
)

;; Treasury functions
(define-public (deposit (guild-id uint) (amount uint))
  (let (
    (current-balance (default-to u0 (get balance (map-get? guild-treasury { guild-id: guild-id }))))
  )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set guild-treasury
      { guild-id: guild-id }
      {
        balance: (+ current-balance amount),
        last-updated: block-height
      }
    )
    (ok true)
  )
)
