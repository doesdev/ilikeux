(function ($, window, document) {

    function randomNumbers(from, to) {
        return Math.floor(Math.random() * (to - from) + from);
    }

    function randomBoxInRow(i) {
        var min, max;
        min = (Math.round(i / 10) * 10) + 1;
        max = min + 8;
        return randomNumbers(min, max);
    }

    function boxesText() {
        var sentence;
        sentence = ["this", "is", "just", "an", "excuse", "to", "play", "around", "with", "js"];
        $(".box").each(function (i) {
            if (i % 10 === 0) {
                $(this).append('<p>' + sentence[i.toString().charAt(0)] + '</p>');
            }
        });
    }

    function boxesImages() {
        var images, random_int, boxes, box_for_img;
        images = ["andrew", "focassign", "ifid", "jqvl", "musocrat"];
        boxes = $(".box");
        random_int = randomNumbers(15, 20);
        box_for_img = $.grep(boxes, function (obj, i) {
            if (i % random_int === 0 && i !== 0) {
                return randomBoxInRow(i);
            }
        });
//        console.log(box_for_img);
        $.each(box_for_img, function (i, obj) {
            if (images[i] !== undefined) {
                boxes[obj.toString()].append('<img src="images/' + images[i] + '.png" />');
                boxes[obj.toString()].children("img").css({
                    width: $(this).outerWidth()
//                    height: $(this).height()
                });
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
            border = colors[randomNumbers(0, colors.length)];
            boxes_wrapper.append('<div class="box box-' + border + '"></div>');
            boxes_wrapper.find('.box').css({
                width: box_width,
                height: box_height
            });
            i = i + 1;
        }
        boxesText();
        boxesImages();
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
//        boxesStart();
//        boxBuilder();
    }

    $(window).on("resize", function () {
        sizing();
    });

    $(document).ready(function () {
        sizing();
    });

})(jQuery, window, document);