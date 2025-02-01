;; Guild Core Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-guild-exists (err u101))
(define-constant err-invalid-name (err u102))

;; Data structures
(define-map guilds
  { guild-id: uint }
  {
    name: (string-ascii 64),
    owner: principal,
    created-at: uint,
    member-count: uint,
    active: bool
  }
)

(define-map guild-members
  { guild-id: uint, member: principal }
  {
    joined-at: uint,
    role: (string-ascii 20),
    active: bool
  }
)

;; Guild creation
(define-public (create-guild (name (string-ascii 64)))
  (let ((guild-id (var-get next-guild-id)))
    (asserts! (is-valid-name name) err-invalid-name)
    (asserts! (not (guild-exists guild-id)) err-guild-exists)
    
    (map-set guilds
      { guild-id: guild-id }
      {
        name: name,
        owner: tx-sender,
        created-at: block-height,
        member-count: u1,
        active: true
      }
    )
    
    (map-set guild-members
      { guild-id: guild-id, member: tx-sender }
      {
        joined-at: block-height,
        role: "owner",
        active: true  
      }
    )
    
    (var-set next-guild-id (+ guild-id u1))
    (ok guild-id))
)
