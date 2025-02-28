;; Guild Treasury Contract

;; Constants
(define-constant err-insufficient-funds (err u200))
(define-constant err-unauthorized (err u201))
(define-constant err-invalid-amount (err u202))

;; Data structures
(define-map guild-treasury
  { guild-id: uint }
  {
    balance: uint,
    last-updated: uint
  }
)

;; Read only functions
(define-read-only (get-treasury-balance (guild-id uint))
  (default-to u0 (get balance (map-get? guild-treasury { guild-id: guild-id })))
)

;; Treasury functions
(define-public (deposit (guild-id uint) (amount uint))
  (let (
    (current-balance (get-treasury-balance guild-id))
  )
    (asserts! (> amount u0) err-invalid-amount)
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

(define-public (withdraw (guild-id uint) (amount uint))
  (let (
    (current-balance (get-treasury-balance guild-id))
  )
    (asserts! (is-guild-admin guild-id tx-sender) err-unauthorized)
    (asserts! (>= current-balance amount) err-insufficient-funds)
    (asserts! (> amount u0) err-invalid-amount)
    
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (map-set guild-treasury
      { guild-id: guild-id }
      {
        balance: (- current-balance amount),
        last-updated: block-height
      }
    )
    (ok true)
  )
)
