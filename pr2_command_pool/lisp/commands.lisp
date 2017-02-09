(in-package :pr2-command-pool-package)

(defun close-gripper (arm &optional  (strength 50))
  "Call action to close gripper."
  (action-move-gripper 0.0 arm strength))

(defun open-gripper (arm)
  "Call action to open gripper."
  (action-move-gripper 0.09 arm 70))

(defun is-object-in-view (object-id)
  T)

(defun get-object-info (object-name)
  "Get object infos using prolog interface."
  (cut:with-vars-bound
      (?frame ?timestamp ?width ?height ?depth)
      (prolog-get-object-infos object-name)
    (make-object-info
       :name object-name
       :frame (string-downcase ?frame)
       :timestamp ?timestamp
       :height ?height
       :width ?width
       :depth ?depth)))

(defun move-arm-to-object (obj-info arm)
  "Call action to move arm to an object."
  (let ((arm-str (if (string= arm +left-arm+) "left" "right")))
    (action-move-robot (format nil "pr2_upper_body_~a_arm" arm-str)
                       (format nil "pr2_grasp_control_~a" arm)
                       (make-param +transform+ nil "object_frame"
                                   (format nil "~a ~a" (object-info-name obj-info) "base_link")) 
                       (make-param +double+ T "object_width" (write-to-string (object-info-width obj-info)))
                       (make-param +double+ T "object_height" (write-to-string (object-info-height obj-info))))))

(defun move-object-with-arm (loc-info obj-info arm)
  "Call action to place an object at a location."
  (let ((arm-str (if (string= arm +left-arm+) "left" "right")))
    (action-move-robot (format nil "pr2_upper_body_~a_arm" arm-str)
                       (format nil "pr2_place_control_~a" arm)
                       (make-param +transform+ T "location_frame"
                                   (format nil "~a ~a" (object-info-frame loc-info) "/base_link"))
                       (make-param +transform+ T "object_frame"
                                   (format nil "~a ~a" (object-info-frame obj-info) "/base_link"))
                       (make-param +double+ T "object_width" (write-to-string (object-info-width obj-info)))
                       (make-param +double+ T "object_height" (write-to-string (object-info-height obj-info)))
                       (make-param +double+ T (format nil "~a_gripper_effort" arm) (write-to-string 50)))))

(defun get-in-base-pose ()
  "Bring PR2 into base (mantis) pose."
  (action-move-robot "pr2_upper_body" "pr2_upper_body_joint_control"
                     (make-param +double+ T "torso_lift_joint" "0.25")
                     (make-param +double+ T "l_shoulder_pan_joint" "1.23679")
                     (make-param +double+ T "l_shoulder_lift_joint" "-0.247593")
                     (make-param +double+ T "l_upper_arm_roll_joint" "0.614271")
                     (make-param +double+ T "l_elbow_flex_joint" "-1.38094")
                     (make-param +double+ T "l_forearm_roll_joint" "-4.94757")
                     (make-param +double+ T "l_wrist_flex_joint" "-1.56861")
                     (make-param +double+ T "l_wrist_roll_joint" "0")
                     (make-param +double+ T "r_shoulder_pan_joint" "-1.23679")
                     (make-param +double+ T "r_shoulder_lift_joint" "-0.247593")
                     (make-param +double+ T "r_upper_arm_roll_joint" "-0.614271")
                     (make-param +double+ T "r_elbow_flex_joint" "-1.38094")
                     (make-param +double+ T "r_forearm_roll_joint" "4.94757")
                     (make-param +double+ T "r_wrist_flex_joint" "-1.56861")
                     (make-param +double+ T "r_wrist_roll_joint" "0")))

(defun slice (obj-info)
  (print "slicing")
  (print obj-info))

(defun push-aside (obj-info)
  (print "push aside")
  (print obj-info))
