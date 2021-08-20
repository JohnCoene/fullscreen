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

document.onload = supportShiny();
