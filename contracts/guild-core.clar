;; Guild Core Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-guild-exists (err u101))
(define-constant err-invalid-name (err u102))
(define-constant err-not-member (err u103))
(define-constant err-already-member (err u104))

;; Data variables
(define-data-var next-guild-id uint u1)

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

;; Read only functions
(define-read-only (get-guild (guild-id uint))
  (map-get? guilds { guild-id: guild-id })
)

(define-read-only (is-guild-member (guild-id uint) (member principal))
  (default-to false (get active (map-get? guild-members { guild-id: guild-id, member: member })))
)

(define-read-only (is-guild-admin (guild-id uint) (member principal))
  (let ((member-info (map-get? guild-members { guild-id: guild-id, member: member })))
    (and
      (is-some member-info)
      (is-eq (get role (unwrap-panic member-info)) "admin")
    )
  )
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

;; Member management
(define-public (join-guild (guild-id uint))
  (let ((guild (unwrap! (get-guild guild-id) err-guild-exists)))
    (asserts! (not (is-guild-member guild-id tx-sender)) err-already-member)
    
    (map-set guild-members
      { guild-id: guild-id, member: tx-sender }
      {
        joined-at: block-height,
        role: "member",
        active: true
      }
    )
    
    (map-set guilds
      { guild-id: guild-id }
      (merge guild { member-count: (+ (get member-count guild) u1) })
    )
    (ok true))
)

(define-public (leave-guild (guild-id uint))
  (let ((guild (unwrap! (get-guild guild-id) err-guild-exists)))
    (asserts! (is-guild-member guild-id tx-sender) err-not-member)
    
    (map-set guild-members
      { guild-id: guild-id, member: tx-sender }
      {
        joined-at: block-height,
        role: "member",
        active: false
      }
    )
    
    (map-set guilds
      { guild-id: guild-id }
      (merge guild { member-count: (- (get member-count guild) u1) })
    )
    (ok true))
)
