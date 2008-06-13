// 292929	5B7876	8F9E8B	F2E6B6	412A22

function restripe(restripe_me)
{  
	$$('#' + restripe_me + ' .stripe').each(function(element, i){
			var className = i % 2 == 0 ? "odd" : "even"
			element.removeClassName('odd')
			element.removeClassName('even')
			element.addClassName(className)
	})  


}

