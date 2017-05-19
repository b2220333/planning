(in-package :plan-execution-package)

(def-fact-group move-robot-actions (action-desig)
  "cram fact-group for referencing action designators.
See cram documentation for further information."
  ; grasp
  (<- (action-desig ?desig (grasp ((arm ?arm) (obj-info ?obj-info))))
    (desig-prop ?desig (:type :grasp))
    (desig-prop ?desig (:arm ?arm))
    (desig-prop ?desig (:object ?object))
    (lisp-fun common:get-object-info ?object ?obj-info))

  ;; move-with-arm
  (<- (action-desig ?desig (move-with-arm ((arm ?arm) (obj-info ?obj-info) (target-info ?target-info))))
    (desig-prop ?desig (:type :move-with-arm))
    (desig-prop ?desig (:arm ?arm))
    (desig-prop ?desig (:target ?target))
    (desig-prop ?desig (:object ?object))
    ; get target-info
    (lisp-fun common:make-object-info :name ?target ?target-info)
    ; get object-info
    (lisp-fun common:make-object-info :name ?object ?object-info))

  ; place
  (<- (action-desig ?desig (place ((arm ?arm) (obj-info ?obj-info) (target ?target))))
    (desig-prop ?desig (:type :place))
    (desig-prop ?desig (:arm ?arm))
    (desig-prop ?desig (:target ?target))
    (desig-prop ?desig (:object ?object))
    (lisp-fun common:get-object-info ?target ?obj-info)
    (lisp-fun common:get-object-info ?object ?obj-info))

  ; detach
  (<- (action-desig ?desig (cut ((arm ?arm) (obj-info ?obj-info))))
      (desig-prop ?desig (:type :detach))
      (desig-prop ?desig (:arm ?arm))
      (desig-prop ?desig (:object ?object))
      (lisp-fun common:get-object-info ?object ?obj-info))

  
  ;; cut
  ;; with pushing
  (<- (action-desig ?desig (cut ((arm ?arm) (knife ?knife-info) (cake ?cake-info) (target ?target-info))))
    (desig-prop ?desig (:type :cut))
    (desig-prop ?desig (:arm ?arm))
    (desig-prop ?desig (:knife ?knife))
    (desig-prop ?desig (:cake ?cake))
    (desig-prop ?desig (:target ?target))
    (lisp-fun common:get-object-info ?knife ?knife-info)
    (lisp-fun common:get-object-info ?cake ?cake-info)
    (lisp-fun common:make-object-info :name ?target ?target-info))
    

  ;; without pushing
  (<- (action-desig ?desig (cut ((arm ?arm) (knife ?knife-info) (cake ?cake-info))))
    (desig-prop ?desig (:type :cut))
    (desig-prop ?desig (:arm ?arm))
    (desig-prop ?desig (:knife ?knife))
    (desig-prop ?desig (:cake ?cake))
    (lisp-fun common:get-object-info ?knife ?knife-info)
    (lisp-fun common:get-object-info ?cake ?cake-info))

  
  ;; move-n-flip
  (<- (action-desig ?desig (move-n-flip ((arm ?arm) (tool ?tool-info) (target ?tool-info))))
    (desig-prop ?desig (:type :move-n-flip))
    (desig-prop ?desig (:arm ?arm))
    (desig-prop ?desig (:tool ?tool))
    (desig-prop ?desig (:target ?target))
    (lisp-fun common:make-object-info :name ?tool ?tool-info)
    (lisp-fun common:get-object-info ?target ?target-info))

  ; test
  (<- (action-desig ?desig (test ((obj-info ?obj-info))))
    (desig-prop ?desig (:type :test))))
  
