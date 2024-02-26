function toggleNav(target, element) {
  var targetContainer = document.getElementById(target);
  var targetTrigger = element;

  if (window.getComputedStyle(targetContainer).display === "none") {
      targetContainer.style.display = "block";
      element.classList.add("nav-active"); 
  } else {
      targetContainer.style.display = "none";
      element.classList.remove("nav-active"); 
  }
};


// Category Toggle
function toggleCategory(target, element){
  var targetContainer = document.getElementById(target);
  var targetTrigger = element;

  if (window.getComputedStyle(targetContainer).display === "none") {
      targetContainer.style.display = "block";
      element.classList.add("category-active"); 
  } else {
      targetContainer.style.display = "none";
      element.classList.remove("category-active"); 
  }
};

// Drawer Toggle
function toggleDrawer(target, element){
  var targetContainer = document.getElementById(target);
  var targetTrigger = element;

  if (window.getComputedStyle(targetContainer).display === "none") {
      targetContainer.style.display = "block";
      element.classList.add("drawer-active"); 
  } else {
      targetContainer.style.display = "none";
      element.classList.remove("drawer-active"); 
  }
};

function closeActiveDropdowns(){

  const collection = document.getElementsByClassName("dropdown-active");
  for (let i = 0; i < collection.length; i++) {
    collection[i].style.display = 'none';
    collection[i].classList.remove('dropdown-active');
  }

}

function switchDialog(source, target) {
  Fancybox.close([{ src: "#" + source }]);

  Fancybox.show([{ 
    src: "#" + target, 
    compact: true,
    closeButton: false,
    backdropClick: false,
    autoFocus: false
  }]);
};


function openTag(){
  document.getElementById('sticky-tag-container').classList.add("visible");
};

function closeTag(){
  document.getElementById('sticky-tag-container').classList.remove("visible");
};



// Show/Hide Div
function toggleDiv(target, element){
  var targetContainer = document.getElementById(target);
  var targetTrigger = element;

  if (window.getComputedStyle(targetContainer).display === "none") {
      targetContainer.style.display = "block";
  } else {
      targetContainer.style.display = "none";
  }
};


// Dropdown Panels
function toggleDropdown(target, element) {
    var targetContainer = document.getElementById(target);
    var targetTrigger = element;
    var triggerID = element.id;
  
    if (window.getComputedStyle(targetContainer).display === "none") {
        // Hide any open dropdowns first
        var activeDropdowns = document.getElementsByClassName('dropdown-active');
        for (var i = 0; i < activeDropdowns.length; ++i) {
            var item = activeDropdowns[i];  
            item.style.display = "none";
            item.classList.remove("dropdown-active");
        }
        targetContainer.style.display = "block";
        targetContainer.classList.add("dropdown-active");

        const specifiedElement = targetContainer;

        // Add event listener when panel is open
        // document.addEventListener('click', function(srcEvent){
        //     const isClickInside = specifiedElement.contains(event.target)

        //     if ((!isClickInside) && (!(srcEvent.srcElement.id == triggerID))) {

        //         specifiedElement.style.display = "none";
        //         specifiedElement.classList.remove("dropdown-active");
        //     }
        // })

    } else {
        targetContainer.style.display = "none";
        targetContainer.classList.remove("dropdown-active");
    }

};


// Show/Hide Delivery Day Details 
function toggleDeliveryDay(target, element){
  var targetContainer = document.getElementById(target);
  var targetTrigger = element;

  if (window.getComputedStyle(targetContainer).display === "none") {
      targetContainer.style.display = "block";
      element.classList.remove("btn-active"); 
      document.getElementById(target).nextElementSibling.classList.remove('collapsed-day');
  } else {
      targetContainer.style.display = "none";
      element.classList.add("btn-active"); 
      document.getElementById(target).nextElementSibling.classList.add('collapsed-day');
  }
};




