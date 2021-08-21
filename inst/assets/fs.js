function supportShiny(){
	console.log(Shiny);
	if(!Shiny)
		return;

	Shiny.addCustomMessageHandler('fs-trigger', function(msg){

		if(!msg.target){
			screenfull.request();
			return;
		}

		const element = document.getElementById(msg.target);
		screenfull.request(element);

	});
}

function fsTrigger(id, target) {
	document.getElementById(id).addEventListener('click', function(){

		if(target){
			let element = document.getElementById(target);
			if (screenfull.isEnabled) {
				screenfull.request(element);
			}
			return ;
		}
		
		screenfull.request();
	});

}

document.onload = supportShiny();
