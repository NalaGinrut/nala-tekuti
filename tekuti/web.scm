1;3202;0c;; Tekuti
;; Copyright (C) 2008, 2010, 2011, 2012 Andy Wingo <wingo at pobox dot com>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, contact:
;;
;; Free Software Foundation           Voice:  +1-617-542-5942
;; 59 Temple Place - Suite 330        Fax:    +1-617-542-2652
;; Boston, MA  02111-1307,  USA       gnu@gnu.org

;;; Commentary:
;;
;; This is the main script that will launch tekuti.
;;
;;; Code:

(define-module (tekuti web)
  #:use-module (web server)
  #:use-module (web request)
  #:use-module (web uri)
  #:use-module (tekuti cache)
  #:use-module (tekuti request)
  #:use-module (tekuti index)
  #:use-module (tekuti page)
  #:use-module (tekuti page-helpers)
  #:use-module (tekuti config)
  #:export (main-loop))

(define (choose-handler request)
  (format #t "[PATH]: ~a~%" (uri-path (request-uri request)))
  (format #t "[METHOD]: ~a~%" (request-method request))
  (request-path-case
   request
   ((GET mylifeasadog) page-admin)
   ((GET mylifeasadog posts) page-admin-posts)
   ((GET mylifeasadog posts post-key!) page-admin-post)
   ((POST mylifeasadog new-post) page-admin-new-post)
   ;; would be fine to have e.g. (DELETE mylifeasadog posts posts-key!), but
   ;; web browsers don't handle that
   ((POST mylifeasadog delete-post post-key!) page-admin-delete-post)
   ((POST mylifeasadog modify-post post-key!) page-admin-modify-post)
   ((POST mylifeasadog delete-comment post-key! comment-id!) page-admin-delete-comment)
   ((GET mylifeasadog changes) page-admin-changes)
   ((GET mylifeasadog changes sha1!) page-admin-change)
   ((POST mylifeasadog revert-change sha1!) page-admin-revert-change)
   ((GET) page-index)
   ((GET archives year? month? day?) page-archives)
   ((GET archives year! month! day! post!) page-show-post)
   ((POST archives year! month! day! post!) page-new-comment)
   ((GET feed) page-feed-atom)
   ((GET feed atom) page-feed-atom)
   ((POST search) page-search)
   ((GET tags) page-show-tags)
   ((GET tags tag!) page-show-tag)
   ;; ((GET debug) page-debug)
   ;; extra pages 
   ((GET about) (extra-page-emit "about"))
   ((GET projects) (lambda (r b i) (respond "" #:host "https://github.com" #:redirect (relurl '("NalaGinrut")))))
   ((GET writings) (extra-page-emit "writings"))
   ((GET community) (lambda (r b i) (respond "" #:host "http://szdiy.org" #:redirect (relurl '()))))
   (else page-not-found)))

(define (cache-ref index request)
  (cached-response-and-body (assq-ref index 'cache) request))

(define (cache-set index request response body)
  (update-index
   (maybe-reindex index)
   'cache
   (lambda (index)
     (update-cache (assq-ref index 'cache) request response body))))

(define (handler request body index)
  (let ((index (maybe-reindex index)))
    (cond
     ((cache-ref index request)
      => (lambda (cached)
           (values (car cached) (cdr cached) index)))
     (else
      (call-with-values (lambda ()
                          ((choose-handler request) request body index))
        (lambda (response body)
          (call-with-values (lambda ()
                              (sanitize-response request response body))
            (lambda (response body)
              (let ((index (cache-set index request response body)))
                (values response body index))))))))))

;; The seemingly useless lambda is to allow for `handler' to be
;; redefined at runtime.
(define (main-loop)
  (run-server (lambda (r b i) (handler r b i))
              *server-impl*
              (if (list? *server-impl-args*)
                  *server-impl-args*
                  (*server-impl-args*))
              (read-index)))
