;; Guild Reputation Contract

;; Constants
(define-constant err-invalid-score (err u300))

;; Data structures
(define-map member-reputation
  { guild-id: uint, member: principal }
  {
    score: uint,
    last-updated: uint
  }
)

;; Reputation functions  
(define-public (update-reputation (guild-id uint) (member principal) (score uint))
  (begin
    (asserts! (is-guild-admin guild-id tx-sender) err-unauthorized)
    (asserts! (< score u100) err-invalid-score)
    
    (map-set member-reputation
      { guild-id: guild-id, member: member }
      {
        score: score,
        last-updated: block-height
      }
    )
    (ok true))
)
