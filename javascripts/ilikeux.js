(function ($, window, document) {

    function boxesText() {
        $(".box").each(function (i) {
            if (i === 0) {
                this.innerHTML = "this";
            } else if (i === 11) {
                this.innerHTML = "is";
            } else if (i === 22) {
                this.innerHTML = "just";
            } else if (i === 33) {
                this.innerHTML = "an";
            } else if (i === 44) {
                this.innerHTML = "excuse";
            } else if (i === 55) {
                this.innerHTML = "to";
            } else if (i === 66) {
                this.innerHTML = "play";
            } else if (i === 77) {
                this.innerHTML = "around";
            } else if (i === 88) {
                this.innerHTML = "with";
            } else if (i === 99) {
                this.innerHTML = "js";
            }
        });
    }

    function boxBuilder() {
        var i, boxes_wrapper, wrapper_height, box_width, box_height, colors, border;
        i = 0;
        boxes_wrapper = $("#boxes");
        wrapper_height = boxes_wrapper.outerHeight() - ($("header").outerHeight() + 4);
        box_width = boxes_wrapper.outerWidth() / 10 - 10;
        box_height = wrapper_height / 10 - 10;
        boxes_wrapper.empty();
        colors = ["havelock", "malibu", "nevada", "edward", "pomegranate"];

        while (i < 100) {
            border = colors[Math.floor(Math.random() * colors.length)];
            boxes_wrapper.append('<div class="box box-' + border + '"></div>');
            boxes_wrapper.find('.box').css({
                width: box_width,
                height: box_height
            });
            i = i + 1;
        }
        boxesText();
    }

    function boxesStart() {
        $("#boxes").css("top", ($("header").outerHeight() + 8) + "px");
    }

    function fontScaling(font_factor) {
        var calculate_font, font_size;
        calculate_font = Math.abs(100 - $(window).outerWidth() / 10) + 100;
        font_size = (calculate_font < font_factor) ? calculate_font : font_factor;
        $('body').css("font-size", font_size + "%");
    }

    function sizing() {
        if ($(window).outerWidth() < 750) {
            fontScaling(90);
        } else {
            fontScaling(125);
        }
        boxesStart();
        boxBuilder();
    }

    $(window).on("resize", function () {
        sizing();
    });

    $(document).ready(function () {
        sizing();
    });

})(jQuery, window, document);