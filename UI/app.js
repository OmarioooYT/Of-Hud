// $(".hud-car").hide()
let HudFunctions = {
    HudSimple: function (Voice, Health, armour, Eat, Water, Strees, Walk, proxmity, breath) {
        // $(".hud-main").show()
        
        if (Voice == true) {
            $("#Mic-Icon").removeClass("fa-sharp fa-light fa-microphone-slash");
            $("#Mic-Icon").addClass("fa-sharp fa-light far fa-microphone");
            $("#mic-pressent").css("background", "#46C791");
        }
        else {
            $("#Mic-Icon").removeClass("fa-sharp fa-light far fa-microphone");
            $("#Mic-Icon").addClass("fa-sharp fa-light fa-microphone-slash");
            $("#mic-pressent").css("background", "#B9B9BD");
        }

        if (armour <= 0) {
            $("#armor").fadeOut(500);
            $("#armorhud").fadeOut(500);
        } else {
            $("#armor").fadeIn(500);
            $("#armorhud").fadeIn(500);
        }

        if (Strees <= 0) {
            $("#strees").fadeOut(500);
            $("#streeshud").fadeOut(500);
        } else {
            $("#strees").fadeIn(500);
            $("#streeshud").fadeIn(500);
        }
        

        if (armour <= 60) {
            $("#armor-pressent").addClass("lowarmor");
        } else {
            $("#armor-pressent").removeClass("lowarmor");
        }
        

    

        if (Walk <= 90) {
            $("#walk").fadeIn(500);
            $("#walkhud").fadeIn(500);
            $("#walk-pressent").addClass("lowwa");
        } else {
            $("#walk").fadeOut(500);
            $("#walkhud").fadeOut(500);
            $("#walk-pressent").removeClass("lowwa");
        }

        if (Health < 60) {
            $("#health-pressent").addClass("lowh");
        } else {
            $("#health-pressent").removeClass("lowh");
        }

        if (Health < 90) {
            $("#health").fadeIn(500);
            $("#healthhud").fadeIn(500);
        } else {
            $("#health").fadeOut(500);
            $("#healthhud").fadeOut(500);
        }

        if (breath < 60) {
            $("#oxygen-pressent").addClass("lowox");
        } else {
            $("#oxygen-pressent").removeClass("lowox");
        }

        if (breath < 90) {
            $("#oxygen").fadeIn(500);
            $("#oxygenhud").fadeIn(500);
        } else {
            $("#oxygen").fadeOut(500);
            $("#oxygenhud").fadeOut(500);
        }

        if (Eat < 50) {
            $("#eat-pressent").addClass("lowf");
        } else {
            $("#eat-pressent").removeClass("lowf");
        }

        if (Water < 50) {
            $("#water-pressent").addClass("loww");
        } else {
            $("#water-pressent").removeClass("loww");
        }

        if (Strees > 30) {
            $("#strees-pressent").addClass("lows");
        } else {
            $("#strees-pressent").removeClass("lows");
        }

        if (proxmity === "whisper") {

            $("#svg-mic").css("height", `${100 + 30}%`);

        } else if (proxmity === "normal") {

            $("#svg-mic").css("height", `${100 + 50}%`);

        } else if (proxmity === "loud") {

            $("#svg-mic").css("height", `${100 + 100}%`);

        }

        $("#svg-health").css("height", `${100 + Health}%`);
        $("#svg-armor").css("height", `${100 + armour}%`);
        $("#svg-eat").css("height", `${100 + Eat}%`);
        $("#svg-water").css("height", `${100 + Water}%`);
        $("#svg-strees").css("height", `${100 + Strees}%`);
        $("#svg-walk").css("height", `${100 + Walk}%`);
        $("#svg-oxygen").css("height", `${100 + breath}%`);
    },
    HudCar: function (StreetName, Fuel, Engine, Speed, Gear , SeatBelt, waydist, directions) {
        $(".hud-car").fadeIn(500);
        $(".streeat-name").html(StreetName)
        $("#svg-fuel").css("height", `${100 + Fuel}%`);
        $("#svg-engine").css("height" , `${100 +Engine / 10}%`);
        $(".gear-label").html(Gear);

        if (Engine / 10 < 60) {
            $("#svg-pressent-engine").addClass("lowengine");
        } else {
            $("#svg-pressent-engine").removeClass("lowengine");
        }

        if (Fuel < 60) {
            $("#svg-pressent-fuel").addClass("lowfuel");
        } else {
            $("#svg-pressent-fuel").removeClass("lowfuel");
        }

        if (Gear === 0) {
            $(".gear-label").html("R");
        } else {
            $(".gear-label").html(Gear);
        }


        if (directions === "Front") {

            $(".left").html(`<i class="fa-solid fa-arrow-up"></i>`);

        } else if (directions === "Back") {

            $(".left").html(`<i class="fa-solid fa-arrow-turn-left-down"></i>`);

        } else if (directions === "Left") {

            $(".left").html(`<i class="fa-solid fa-arrow-left"></i>`);

        } else if (directions === "Right") {

            $(".left").html(`<i class="fa-solid fa-arrow-right"></i>`);

        } else if (directions === "Halfright") {

            $(".left").html(`<i class="fa-regular fa-arrow-up-right"></i>`);

        } else if (directions === "Halfleft") {

            $(".left").html(`<i class="fa-regular fa-arrow-up-left"></i>`);

        } else if (directions === "None") {

            $(".left").html(`<i class="fa-sharp fa-solid fa-location-crosshairs-slash"></i>`);

        }

        if (waydist >= 0) {
            $(".waypoint").html((waydist).toFixed(1) + " KM")
        }else{
            $(".waypoint").html("--")
        }


        //    if (Speed > 100) {


        if (Speed == 0) {
            $(".km").html('<span >' + "000" + '</span>');
            
            }else{
                $(".km").html('<span >' + "00" + '<span >' + Speed + '</span>' + '</span>');
            }
            if (Speed > 9) {
                $(".km").html('<span >' + "0" + '<span >' + Speed + '</span>' + '</span>');
            }
            if (Speed > 99) {
                $(".km").html(Speed);
            }
        

        if (SeatBelt === true) {
            $(".seat-circle").fadeOut(500)
        }else{
            $(".seat-circle").fadeIn(500)
        }
        
        //  console.log(Engine / 10)
    },
    updateRPM : function (rpm) {
        var rpmBar = document.getElementById('rpmBar');
        if (rpmBar) {
            var items = rpmBar.getElementsByClassName('seggement');
            for (var i = 0; i < 17; i++) {
                var item;
                if (items[i]) {
                    item = items[i];
                }
                item.classList.remove('filled', 'between', 'critical');
                if (i < rpm) {
                    if (i >= 14) {
                        item.classList.add('critical');
                    } else if (i >= 11) {
                        item.classList.add('between');
                    } else {
                        item.classList.add('filled');
                    }
                }
            }
        } else {
            //console.log("Element with ID 'rpmBar' not found");
        } 
    }
}


window.addEventListener('message', (event) => {
    let data = event.data
    if (data.action === true) {
        switch (data.type) {
            case "SimpleHud":
                $(".hud-main").css("display", "flex");
                $(".hud-car").fadeOut(500);
                $(".hud-main").fadeIn(500);
                HudFunctions.HudSimple(data.voice, data.health, data.armour, data.food, data.thirst, data.stress, data.stamina, data.proxmity, data.breath)
                break;
            case "CarHud":
                $(".hud-car").css("display", "block");
                $(".hud-main").css("display", "flex");
                HudFunctions.HudSimple(data.voice, data.health, data.armour, data.food, data.thirst, data.stress, data.stamina, data.proxmity, (data.breath) *100)
                HudFunctions.HudCar(data.area, data.fuel, data.enginerun, data.vehspeed, data.gear , data.seatbelt, data.waydist, data.directions)
                HudFunctions.updateRPM((data.rpm / 1) * 18)
                break;
            default:
                break;
        }

    } else if (data.action === false) {
        switch (data.type) {
            case "SimpleHud":
                $(".hud-main").fadeOut(500);
                $(".hud-main").css("display", "none");
                break;
            case "CarHud":
                $(".hud-car").css("display", "none");
                $(".hud-car").fadeOut(500);
                $(".hud-main").fadeOut(500);
                break;
            default:
                break;
        }
    }

})


// window.addEventListener('message', function(event) {
//     var rpm = event.data.rpm;
//     if (rpm !== undefined) {
//         //console.log("Received RPM: " + rpm);
//         updateRPM((rpm / 1) * 18);
//     } else {
//         //console.log("RPM data not received");
//     }
// });
// // HudFunctions.HudSimple(true , 50 , 75 ,50 , 100 , 50 , 100)