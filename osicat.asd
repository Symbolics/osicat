;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-
;;;
;;; osicat.asd --- ASDF system definition.
;;;
;;; Copyright (C) 2007, Luis Oliveira  <loliveira@common-lisp.net>
;;;
;;; Permission is hereby granted, free of charge, to any person
;;; obtaining a copy of this software and associated documentation
;;; files (the "Software"), to deal in the Software without
;;; restriction, including without limitation the rights to use, copy,
;;; modify, merge, publish, distribute, sublicense, and/or sell copies
;;; of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be
;;; included in all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;; NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.

#.(unless (or #+asdf3.1 (version<= "3.1" (asdf-version)))
    (error "You need ASDF >= 3.1 to load this system correctly."))

(eval-when (:load-toplevel :execute)
  (asdf:load-system 'trivial-features))

(defsystem :osicat
  :author "Nikodemus Siivola <nikodemus@random-state.net>"
  :description "A lightweight operating system interface"
  :license "MIT"
  :depends-on (:alexandria :cffi :trivial-features)
  :defsystem-depends-on (:cffi-grovel)
  :components
  ((:module #:osicat-sys
    :pathname "src/"
    :components
    ((:file "osicat-sys"))))
  :in-order-to ((test-op (test-op :osicat/tests))))

(defsystem "osicat/posix"
  :depends-on (:osicat)
  :pathname "posix/"
  :serial t
  :components
  ((:file "packages")
   (:cffi-grovel-file "basic-unixint")
   (:cffi-grovel-file "unixint" :if-feature (:not :windows))
   (:file "early")
   (:cffi-wrapper-file "wrappers" :soname "libosicat")
   (:file "basic-unix")
   (:file "unix" :if-feature (:not :windows))
   (:file "linux" :if-feature :linux)
   (:file "windows" :if-feature :windows)
   (:file "misc")))

(defsystem "osicat/windows"
  :if-feature :windows
  :depends-on (#:osicat)
  :pathname "windows/"
  :components
  ((:file "package")
   (:file "windows" :depends-on ("package"))))

 (defsystem "osicat/mach"
  :if-feature :darwin
  :depends-on (#:osicat)
  :pathname "mach/"
  :components
          ((:file "package")
           (:file "mach" :depends-on ("package"))))

(defsystem "osicat/src"
  :depends-on (#:osicat
               #:osicat/posix
               (:feature :windows #:windows)
               (:feature :darwin #:mach))
  :pathname "src/"
  :serial t
  :components
    ((:file "packages")
     (:file "fd-streams" :depends-on ("packages"))
     (:file "osicat" :depends-on ("packages" "fd-streams"))
     (:file "time" :depends-on ("packages"))))

(defsystem #:osicat/tests
  :author "Nikodemus Siivola <nikodemus@random-state.net>"
  :description "Osicat test suite"
  :license "MIT"
  :depends-on (#:osicat #:rt)
  :components
  ((:module #:tests
    :serial t
    :components
    ((:file "tests")
     (:file "posix")
     (:file "osicat"))))
  :perform (test-op (o c) (symbol-call :osicat/tests :run)))
