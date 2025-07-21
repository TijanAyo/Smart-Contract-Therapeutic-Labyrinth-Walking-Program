;; ===================================================================
;; SMART CONTRACT THERAPEUTIC LABYRINTH WALKING PROGRAM
;; ===================================================================
;; A comprehensive system for coordinating meditative walking experiences
;; with path maintenance, group sessions, and contemplative outcomes.
;; Integrates accessibility design, spiritual practices, and sacred geometry.
;; ===================================================================

;; ===================================================================
;; CONTRACT 1: LABYRINTH CORE MANAGEMENT
;; ===================================================================

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-LABYRINTH-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-PARAMETERS (err u103))
(define-constant ERR-MAINTENANCE-REQUIRED (err u104))
(define-constant ERR-SESSION-FULL (err u105))
(define-constant ERR-SESSION-NOT-FOUND (err u106))
(define-constant ERR-INVALID-TIME (err u107))
(define-constant ERR-ACCESS-DENIED (err u108))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Sacred geometry patterns (represented as numeric codes)
(define-constant SACRED-CLASSICAL u1)
(define-constant SACRED-CHARTRES u2)
(define-constant SACRED-CRETAN u3)
(define-constant SACRED-BALTIC u4)
(define-constant SACRED-CHAKRA u5)
(define-constant SACRED-CUSTOM u6)

;; Walking session types
(define-constant SESSION-INDIVIDUAL u1)
(define-constant SESSION-GROUP u2)
(define-constant SESSION-THERAPY u3)
(define-constant SESSION-MEDITATION u4)
(define-constant SESSION-HEALING u5)

;; Accessibility levels
(define-constant ACCESS-FULL u1)      ;; Fully accessible
(define-constant ACCESS-ASSISTED u2)  ;; Requires assistance
(define-constant ACCESS-LIMITED u3)   ;; Limited mobility options

;; ===================================================================
;; DATA STRUCTURES
;; ===================================================================

;; Labyrinth registry
(define-map labyrinths
    { labyrinth-id: uint }
    {
        name: (string-ascii 64),
        location: (string-ascii 128),
        sacred-pattern: uint,
        diameter-meters: uint,
        path-width-cm: uint,
        accessibility-level: uint,
        maintenance-score: uint,
        is-active: bool,
        creator: principal,
        creation-block: uint
    }
)

;; Walking sessions registry
(define-map walking-sessions
    { session-id: uint }
    {
        labyrinth-id: uint,
        facilitator: principal,
        session-type: uint,
        scheduled-time: uint,
        duration-minutes: uint,
        max-participants: uint,
        current-participants: uint,
        accessibility-features: (list 10 uint),
        spiritual-focus: (string-ascii 64),
        is-active: bool,
        creation-block: uint
    }
)

;; Session participants
(define-map session-participants
    { session-id: uint, participant: principal }
    {
        joined-at: uint,
        accessibility-needs: (list 5 uint),
        intention: (string-ascii 128),
        experience-level: uint
    }
)

;; Contemplative outcomes tracking
(define-map walking-outcomes
    { outcome-id: uint }
    {
        session-id: uint,
        participant: principal,
        labyrinth-id: uint,
        walking-time-minutes: uint,
        mindfulness-rating: uint,     ;; 1-10 scale
        spiritual-connection: uint,   ;; 1-10 scale
        physical-comfort: uint,       ;; 1-10 scale
        emotional-state-before: uint, ;; 1-10 scale
        emotional-state-after: uint,  ;; 1-10 scale
        insights: (string-ascii 256),
        would-recommend: bool,
        completion-block: uint
    }
)

;; Path maintenance records
(define-map maintenance-records
    { record-id: uint }
    {
        labyrinth-id: uint,
        maintainer: principal,
        maintenance-type: uint,        ;; 1=cleaning, 2=repair, 3=enhancement
        condition-before: uint,        ;; 1-10 scale
        condition-after: uint,         ;; 1-10 scale
        materials-used: (string-ascii 128),
        hours-worked: uint,
        completion-block: uint
    }
)

;; Community reflection spaces
(define-map reflection-spaces
    { space-id: uint }
    {
        labyrinth-id: uint,
        name: (string-ascii 64),
        capacity: uint,
        features: (list 10 uint),      ;; Seating, shade, water, etc.
        is-accessible: bool,
        booking-required: bool,
        manager: principal
    }
)

;; ===================================================================
;; ADMINISTRATIVE FUNCTIONS
;; ===================================================================

;; Counter variables
(define-data-var labyrinth-counter uint u0)
(define-data-var session-counter uint u0)
(define-data-var outcome-counter uint u0)
(define-data-var maintenance-counter uint u0)
(define-data-var reflection-counter uint u0)

;; Get next ID functions
(define-private (get-next-labyrinth-id)
    (let ((current-id (var-get labyrinth-counter)))
        (var-set labyrinth-counter (+ current-id u1))
        (+ current-id u1)
    )
)

(define-private (get-next-session-id)
    (let ((current-id (var-get session-counter)))
        (var-set session-counter (+ current-id u1))
        (+ current-id u1)
    )
)

(define-private (get-next-outcome-id)
    (let ((current-id (var-get outcome-counter)))
        (var-set outcome-counter (+ current-id u1))
        (+ current-id u1)
    )
)

(define-private (get-next-maintenance-id)
    (let ((current-id (var-get maintenance-counter)))
        (var-set maintenance-counter (+ current-id u1))
        (+ current-id u1)
    )
)

(define-private (get-next-reflection-id)
    (let ((current-id (var-get reflection-counter)))
        (var-set reflection-counter (+ current-id u1))
        (+ current-id u1)
    )
)

;; ===================================================================
;; LABYRINTH MANAGEMENT FUNCTIONS
;; ===================================================================

;; Create a new therapeutic labyrinth
(define-public (create-labyrinth
    (name (string-ascii 64))
    (location (string-ascii 128))
    (sacred-pattern uint)
    (diameter-meters uint)
    (path-width-cm uint)
    (accessibility-level uint))

    (let ((labyrinth-id (get-next-labyrinth-id)))
        (asserts! (and (>= sacred-pattern u1) (<= sacred-pattern u6)) ERR-INVALID-PARAMETERS)
        (asserts! (and (>= accessibility-level u1) (<= accessibility-level u3)) ERR-INVALID-PARAMETERS)
        (asserts! (> diameter-meters u0) ERR-INVALID-PARAMETERS)
        (asserts! (>= path-width-cm u60) ERR-INVALID-PARAMETERS) ;; Minimum 60cm for accessibility

        (map-set labyrinths
            { labyrinth-id: labyrinth-id }
            {
                name: name,
                location: location,
                sacred-pattern: sacred-pattern,
                diameter-meters: diameter-meters,
                path-width-cm: path-width-cm,
                accessibility-level: accessibility-level,
                maintenance-score: u10, ;; Start with perfect score
                is-active: true,
                creator: tx-sender,
                creation-block: stacks-block-height
            }
        )
        (ok labyrinth-id)
    )
)

;; Schedule a walking session
(define-public (schedule-walking-session
    (labyrinth-id uint)
    (session-type uint)
    (scheduled-time uint)
    (duration-minutes uint)
    (max-participants uint)
    (accessibility-features (list 10 uint))
    (spiritual-focus (string-ascii 64)))

    (let ((session-id (get-next-session-id))
          (labyrinth (map-get? labyrinths { labyrinth-id: labyrinth-id })))

        (asserts! (is-some labyrinth) ERR-LABYRINTH-NOT-FOUND)
        (asserts! (and (>= session-type u1) (<= session-type u5)) ERR-INVALID-PARAMETERS)
        (asserts! (> scheduled-time stacks-block-height) ERR-INVALID-TIME)
        (asserts! (and (>= duration-minutes u15) (<= duration-minutes u180)) ERR-INVALID-PARAMETERS)
        (asserts! (> max-participants u0) ERR-INVALID-PARAMETERS)

        ;; Check labyrinth maintenance score
        (asserts! (>= (get maintenance-score (unwrap-panic labyrinth)) u7) ERR-MAINTENANCE-REQUIRED)

        (map-set walking-sessions
            { session-id: session-id }
            {
                labyrinth-id: labyrinth-id,
                facilitator: tx-sender,
                session-type: session-type,
                scheduled-time: scheduled-time,
                duration-minutes: duration-minutes,
                max-participants: max-participants,
                current-participants: u0,
                accessibility-features: accessibility-features,
                spiritual-focus: spiritual-focus,
                is-active: true,
                creation-block: stacks-block-height
            }
        )
        (ok session-id)
    )
)

;; Join a walking session
(define-public (join-walking-session
    (session-id uint)
    (accessibility-needs (list 5 uint))
    (intention (string-ascii 128))
    (experience-level uint))

    (let ((session (map-get? walking-sessions { session-id: session-id })))
        (asserts! (is-some session) ERR-SESSION-NOT-FOUND)

        (let ((session-data (unwrap-panic session)))
            (asserts! (< (get current-participants session-data) (get max-participants session-data)) ERR-SESSION-FULL)
            (asserts! (get is-active session-data) ERR-SESSION-NOT-FOUND)
            (asserts! (and (>= experience-level u1) (<= experience-level u5)) ERR-INVALID-PARAMETERS)

            ;; Check if already joined
            (asserts! (is-none (map-get? session-participants { session-id: session-id, participant: tx-sender })) ERR-ALREADY-EXISTS)

            ;; Add participant
            (map-set session-participants
                { session-id: session-id, participant: tx-sender }
                {
                    joined-at: stacks-block-height,
                    accessibility-needs: accessibility-needs,
                    intention: intention,
                    experience-level: experience-level
                }
            )

            ;; Update session participant count
            (map-set walking-sessions
                { session-id: session-id }
                (merge session-data { current-participants: (+ (get current-participants session-data) u1) })
            )

            (ok true)
        )
    )
)

;; Record walking outcome
(define-public (record-walking-outcome
    (session-id uint)
    (walking-time-minutes uint)
    (mindfulness-rating uint)
    (spiritual-connection uint)
    (physical-comfort uint)
    (emotional-state-before uint)
    (emotional-state-after uint)
    (insights (string-ascii 256))
    (would-recommend bool))

    (let ((outcome-id (get-next-outcome-id))
          (session (map-get? walking-sessions { session-id: session-id }))
          (participant-record (map-get? session-participants { session-id: session-id, participant: tx-sender })))

        (asserts! (is-some session) ERR-SESSION-NOT-FOUND)
        (asserts! (is-some participant-record) ERR-ACCESS-DENIED)
        (asserts! (and (>= mindfulness-rating u1) (<= mindfulness-rating u10)) ERR-INVALID-PARAMETERS)
        (asserts! (and (>= spiritual-connection u1) (<= spiritual-connection u10)) ERR-INVALID-PARAMETERS)
        (asserts! (and (>= physical-comfort u1) (<= physical-comfort u10)) ERR-INVALID-PARAMETERS)
        (asserts! (and (>= emotional-state-before u1) (<= emotional-state-before u10)) ERR-INVALID-PARAMETERS)
        (asserts! (and (>= emotional-state-after u1) (<= emotional-state-after u10)) ERR-INVALID-PARAMETERS)

        (let ((session-data (unwrap-panic session)))
            (map-set walking-outcomes
                { outcome-id: outcome-id }
                {
                    session-id: session-id,
                    participant: tx-sender,
                    labyrinth-id: (get labyrinth-id session-data),
                    walking-time-minutes: walking-time-minutes,
                    mindfulness-rating: mindfulness-rating,
                    spiritual-connection: spiritual-connection,
                    physical-comfort: physical-comfort,
                    emotional-state-before: emotional-state-before,
                    emotional-state-after: emotional-state-after,
                    insights: insights,
                    would-recommend: would-recommend,
                    completion-block: stacks-block-height
                }
            )
            (ok outcome-id)
        )
    )
)

;; Record maintenance activity
(define-public (record-maintenance
    (labyrinth-id uint)
    (maintenance-type uint)
    (condition-before uint)
    (condition-after uint)
    (materials-used (string-ascii 128))
    (hours-worked uint))

    (let ((maintenance-id (get-next-maintenance-id))
          (labyrinth (map-get? labyrinths { labyrinth-id: labyrinth-id })))

        (asserts! (is-some labyrinth) ERR-LABYRINTH-NOT-FOUND)
        (asserts! (and (>= maintenance-type u1) (<= maintenance-type u3)) ERR-INVALID-PARAMETERS)
        (asserts! (and (>= condition-before u1) (<= condition-before u10)) ERR-INVALID-PARAMETERS)
        (asserts! (and (>= condition-after u1) (<= condition-after u10)) ERR-INVALID-PARAMETERS)
        (asserts! (>= condition-after condition-before) ERR-INVALID-PARAMETERS)

        ;; Record maintenance
        (map-set maintenance-records
            { record-id: maintenance-id }
            {
                labyrinth-id: labyrinth-id,
                maintainer: tx-sender,
                maintenance-type: maintenance-type,
                condition-before: condition-before,
                condition-after: condition-after,
                materials-used: materials-used,
                hours-worked: hours-worked,
                completion-block: stacks-block-height
            }
        )

        ;; Update labyrinth maintenance score
        (let ((labyrinth-data (unwrap-panic labyrinth))
              (new-score (min u10 condition-after)))
            (map-set labyrinths
                { labyrinth-id: labyrinth-id }
                (merge labyrinth-data { maintenance-score: new-score })
            )
        )

        (ok maintenance-id)
    )
)

;; Create reflection space
(define-public (create-reflection-space
    (labyrinth-id uint)
    (name (string-ascii 64))
    (capacity uint)
    (features (list 10 uint))
    (is-accessible bool)
    (booking-required bool))

    (let ((space-id (get-next-reflection-id))
          (labyrinth (map-get? labyrinths { labyrinth-id: labyrinth-id })))

        (asserts! (is-some labyrinth) ERR-LABYRINTH-NOT-FOUND)
        (asserts! (> capacity u0) ERR-INVALID-PARAMETERS)

        (map-set reflection-spaces
            { space-id: space-id }
            {
                labyrinth-id: labyrinth-id,
                name: name,
                capacity: capacity,
                features: features,
                is-accessible: is-accessible,
                booking-required: booking-required,
                manager: tx-sender
            }
        )
        (ok space-id)
    )
)

;; ===================================================================
;; READ-ONLY FUNCTIONS
;; ===================================================================

;; Get labyrinth information
(define-read-only (get-labyrinth (labyrinth-id uint))
    (map-get? labyrinths { labyrinth-id: labyrinth-id })
)

;; Get walking session information
(define-read-only (get-walking-session (session-id uint))
    (map-get? walking-sessions { session-id: session-id })
)

;; Get session participant information
(define-read-only (get-session-participant (session-id uint) (participant principal))
    (map-get? session-participants { session-id: session-id, participant: participant })
)

;; Get walking outcome
(define-read-only (get-walking-outcome (outcome-id uint))
    (map-get? walking-outcomes { outcome-id: outcome-id })
)

;; Get maintenance record
(define-read-only (get-maintenance-record (record-id uint))
    (map-get? maintenance-records { record-id: record-id })
)

;; Get reflection space
(define-read-only (get-reflection-space (space-id uint))
    (map-get? reflection-spaces { space-id: space-id })
)

;; Get current counters
(define-read-only (get-system-stats)
    {
        total-labyrinths: (var-get labyrinth-counter),
        total-sessions: (var-get session-counter),
        total-outcomes: (var-get outcome-counter),
        total-maintenance-records: (var-get maintenance-counter),
        total-reflection-spaces: (var-get reflection-counter),
        current-block: stacks-block-height
    }
)

;; Check if session is available for joining
(define-read-only (is-session-available (session-id uint))
    (match (map-get? walking-sessions { session-id: session-id })
        session-data
            (and
                (get is-active session-data)
                (< (get current-participants session-data) (get max-participants session-data))
                (> (get scheduled-time session-data) stacks-block-height)
            )
        false
    )
)

;; Calculate wellness improvement score
(define-read-only (calculate-wellness-improvement (outcome-id uint))
    (match (map-get? walking-outcomes { outcome-id: outcome-id })
        outcome-data
            (let ((emotional-improvement (- (get emotional-state-after outcome-data) (get emotional-state-before outcome-data)))
                  (overall-rating (/ (+ (get mindfulness-rating outcome-data)
                                       (get spiritual-connection outcome-data)
                                       (get physical-comfort outcome-data)) u3)))
                {
                    emotional-improvement: emotional-improvement,
                    overall-rating: overall-rating,
                    wellness-score: (+ overall-rating (if (> emotional-improvement 0) emotional-improvement u0))
                }
            )
        none
    )
)

;; Get labyrinth accessibility features
(define-read-only (get-accessibility-info (labyrinth-id uint))
    (match (map-get? labyrinths { labyrinth-id: labyrinth-id })
        labyrinth-data
            {
                accessibility-level: (get accessibility-level labyrinth-data),
                path-width-cm: (get path-width-cm labyrinth-data),
                maintenance-score: (get maintenance-score labyrinth-data),
                is-suitable-for-mobility-aids: (>= (get path-width-cm labyrinth-data) u90),
                maintenance-status: (if (>= (get maintenance-score labyrinth-data) u8) "excellent"
                                   (if (>= (get maintenance-score labyrinth-data) u6) "good"
                                   (if (>= (get maintenance-score labyrinth-data) u4) "fair" "needs-maintenance")))
            }
        none
    )
)
