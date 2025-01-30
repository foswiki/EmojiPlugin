"use strict";
jQuery(function($) {
   var timer;

   function filterContainer(val) {
      var regex = new RegExp(val, "i");

      $(".container").each(function() {
         var $container = $(this);

         //console.log("filterContainer(",val,")");
         if (val === '') {
            $container.children(".entry").show();
         } else {
            $container.children(".entry").hide().each(function() {
               var $this = $(this),
                   text = $this.text() + " " + $this.find("img").attr("title");

               if (regex.test(text)) {
                  $this.show();
               }
            });
         }

         if ($container.children(".entry:visible").length == 0) {
            $container.prev("h3").hide();
         } else {
            $container.prev("h3").show();
         }
      });
   }
   $(".filterIcons:not(.filterIconsInited").livequery(function() {
      var $input = $(this);
      $input.addClass("filterIconsInited");
      $input.on("keyup", function() {
         if (typeof(timer) !== 'undefined') {
            //console.log("clearing timeout");
            window.clearTimeout(timer);
         }
         timer = window.setTimeout(function() {
            var val = $input.val();
            filterContainer(val);
            timer = undefined;
         }, 100);
         //console.log("new timer",timer);
      });
   });
});