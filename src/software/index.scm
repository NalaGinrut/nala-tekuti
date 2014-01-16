(define page
  `(page
    (project
     (@ (name "guile") (href "http://www.gnu.org/software/guile/"))
     "Since late 2009, I co-maintain " (code "guile") ".")

    (project
     (@ (name "tekuti"))
     "A weblog engine written in Scheme, using Git as its persistent store.")

    (project
     (@ (name "guile-rsvg"))
     "RSVG bindings for Guile.")

    (project
     (@ (name "guile-present"))
     "Making presentations in Guile.")

    (project
     (@ (name "guile-charting"))
     "Making graphs and charts in Guile.")

    (project
     (@ (name "guile-cairo") (href "http://home.gna.org/guile-cairo/"))
     "Guile bindings for the Cairo graphics library.")

    (project
     (@ (name "flumotion") (href "http://www.flumotion.net/"))
     "Flumotion is a Free streaming server based on GStreamer, Python,
and Twisted. I hacked this one for work at my old job.")

    (project
     (@ (name "original"))
     "Exports your " (link "http://f-spot.org" "f-spot") " photo
collection to web and shows them with a tag-based interface.")

    (project
     (@ (name "photoblogger"))
     "A small app to help post photos to a web log. Written in
guile-gnome. A bit obsolete now.")

    (project
     (@ (name "guile-lib") (href "http://www.nongnu.org/guile-lib/"))
     "I co-maintain " (code "guile-lib") "now.")

    (project
     (@ (name "guile-gnome") (href "http://www.gnu.org/software/guile-gnome/"))
     "I maintain the "
     (link "http://www.gnu.org/software/guile/" "Guile")
     " bindings to the " 
     (link "http://gnome.org/" "GNOME") " stack of libraries.")

    (project
     (@ (name "soundscrape") (href "http://ambient.2y.net/soundscrape/"))
     "Soundscrape is a programmatic modular synthesizer. It's not
finished yet, but I'm working on it. It's the reason that I wrote "
     (link "#guile-gnome" "guile-gnome") " and work on " 
     (link "#guile-lib" "guile-lib") ".")
     
    (project
     (@ (name "gstreamer") (href "http://gstreamer.net/"))
     "I've hacked on GStreamer a bit in the past (pre-0.8 times),
and quite a bit in the 0.8 to 0.10 transition. It was the first
collaborative free software project I got involved in. I feel
like I really came of age there.")

    (project
     (@ (name "jaquemate"))
     "The first free software project I worked on was one of these
one-person " (link "http://freshmeat.net/" "freshmeat") " wonders when
you always having a terminal window open running "
     (code "tail -f /var/log/apache/access.log") ". I lost interest
after a while.")
     
    (project
     (@ (name "fortran"))
     "In a past life, I studied nuclear engineering at university.
Fortran is almost disturbingly alive and well in engineering and physics
research labs. I wrote up a few pages about my experience, and they
still get some hits today. Suckers! Use a real language!")

    (h2 (@ (class "centered")) "hacks")
    
    (hack
     (@ (name "wp-advogato") (href "../pub/advogato.php.txt"))
     "A plugin for cross-posting entries from "
     (link "http://wordpress.org/" "wordpress") " to "
     (link "http://advogato.org/" "advogato") ".")))

;; Now output the HTML

(use-modules (sxml simple) (sxml transform))

(load "../template.scm")

(define xhtml-doctype
  (string-append
   "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" "
   "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"))

(define (preprocess page)
 (pre-post-order
  page
  `((page . ,(lambda (tag . body)
               body))
    (project . ,(lambda (tag args . body)
                  `(div (@ (class "project"))
                        (h2 ,(let ((name (cadr (assq 'name (cdr args)))))
                               `(a (@ (href ,(or (and=> (assq 'href (cdr args))
                                                        cadr)
                                                 (string-append name "/")))
                                      (name ,name))
                                   ,name)))
                        (p ,@body))))
    (hack . ,(lambda (tag args . body)
               `(div (@ (class "hack"))
                     (h3 (a ,args ,(cadr (assq 'name (cdr args)))))
                     (p ,@body))))
    (link . ,(lambda (tag href name)
               `(a (@ (href ,href)) ,name)))
    (*text* . ,(lambda (tag text) text))
    (*default* . ,(lambda args args)))))

(define (make-index)
  (display xhtml-doctype)
  (sxml->xml
   (templatize (preprocess page)
               "software"
               "software"
               "../")))
