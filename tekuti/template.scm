;; Tekuti
;; Copyright (C) 2008, 2010, 2012 Andy Wingo <wingo at pobox dot com>

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

(define-module (tekuti template)
  #:use-module (web uri)
  #:use-module (tekuti config)
  #:export (templatize))

(define* (templatize #:key
                     (title *title*)
                     (body '((p "(missing content?)"))))
  (define (href . args)
    `(href ,(string-append "/" (encode-and-join-uri-path
                                (append *public-path-base* args)))))
  (define (list-join l infix)
    "Infixes @var{infix} into list @var{l}."
    (if (null? l) l
        (let lp ((in (cdr l)) (out (list (car l))))
          (cond ((null? in) (reverse out))
                (else (lp (cdr in) (cons* (car in) infix out)))))))
  (define (make-navbar)
    (if (null? *navbar-links*)
        '()
        `((div (@ (id "navbar"))
               ,@(list-join
                  (map (lambda (x) `(a (@ (href ,(cdr x))) ,(car x)))
                       *navbar-links*)
                  *navbar-infix*)))))
  `(html
    (head (title ,title)
          (meta (@ (name "Generator")
                   (content "An unholy concoction of parenthetical guile")))
	  (meta (@ (name "viewport") (content "width=device-width")))
	  (link (@ (rel "shortcut icon") (href "https://nalaginrut.com/blog/mmr.ico")))
          (link (@ (rel "stylesheet")
                   (type "text/css")
                   (media "screen")
                   (href ,*css-file*)))
	  (script (@ (type "text/x-mathjax-config"))
		  "MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\\\(','\\\\)']]}});")
	  (script (@ (type "text/javascript")
		     (src "https://cdn.mathjax.org/mathjax/2.0-latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"))
		  " ") ; NOTE: this whitespace is black magic for SXML in Guile!
	  (script (@ (type "text/javascript") (src "/blog/js/sh_main.min.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_c.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_guile.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_python.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_ruby.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_sh.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_diff.min.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_perl.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_cpp.js")) " ")
	  (script (@ (type "text/javascript") (src "/blog/js/lang/sh_erlang.min.js")) " ")
          (script (@ (type "text/javascript") (src "/blog/js/lang/sh_lua.js")) " ")
	  (link (@ (type "text/css") (rel "stylesheet") (href "/blog/css/sh_emacs.css")))
	  (link (@ (rel "alternate")
                   (type "application/rss+xml")
                   (title ,*title*)
                   (href ,((@ (tekuti page-helpers) relurl) `("feed" "atom"))))))
    (body (@ (onload "sh_highlightDocument();"))
     (div (@ (id "rap"))
          (h1 (@ (id "header"))
              (a (@ ,(href "")) ,*title*))
          ,@(make-navbar)
          (div (@ (id "content")) ,@body)
          (script
           "(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){            
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),                    
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)                   
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');                      
                                                                                                    
  ga('create', 'UA-42113629-1', 'nalaginrut.com');                                                  
  ga('send', 'pageview');")

          (div (@ (id "footer"))
               "powered by "
               (a (@ (href "http://wingolog.org/software/tekuti/"))
                  "tekuti"))))))

