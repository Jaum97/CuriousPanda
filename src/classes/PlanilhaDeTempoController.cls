global class PlanilhaDeTempoController {
	
	public List<Processo__c>  lstProcesso = new List<Processo__c>();
	public Map<String,Boolean> lstInnerMap = new Map<String,Boolean>();

	public List<innerClass> lstInner{get;set;}
	public String selectedRowIndex{get;set;}
	public Integer count = 1;

	public Map<Id,Chamado__c> chamadoMap {set;get;}

	public String selectedChamadoId {set;get;}

	public List<SelectOption> getChamado() {

		this.chamadoMap = new Map<Id,Chamado__C>();

		List<SelectOption> portfolioOptionList = new list<SelectOption>();
		portfolioOptionList.add(new SelectOption('-','-'));

		List<Chamado__c> chamados = [SELECT Id, Name, DescricaoResumida__c, Cliente__r.Name, LancaMesAnterior__c
									FROM Chamado__c 
									WHERE Status__c NOT IN ('Cancelado','Resolvido') AND Atribuicao__c = : userInfo.getUserId()
									ORDER BY Name];

		for ( Chamado__c chamado: chamados  ){

			portfolioOptionList.add(new SelectOption(chamado.id, chamado.Name+': '+ chamado.DescricaoResumida__c));
			this.chamadoMap.put(chamado.Id, chamado);
		
		} 

		return portfolioOptionList;
	}

	public void validarDados(){ 
		for (innerClass ic : this.lstInner){
			Boolean validado = true;
			if (ic.processo.Data__c.month() < Date.today().month()){ 
				ic.processo.Data__c.addError('Data não pode ser de meses anteriores');
				validado = false;
			}
			lstInnerMap.put(ic.recCount,validado);
		}
	}

	public Pagereference Save (){
	
		Pagereference page = new Pagereference('/apex/PlanilhaDeTempo'); 
		Database.UpsertResult[] upResult;
		Set<Id> ids = new Set<Id>();

		validarDados();

		try{
			for (innerClass ic : lstInner){
				if( lstInnerMap.get(ic.recCount) ){
					lstProcesso.add(ic.processo);
				}			
			}

			upResult = Database.Upsert(lstProcesso);
			
			for (Database.UpsertResult sr : upResult){
				if(sr.isSuccess()){
					for (innerClass ic : lstInner){
						if (ic.processo.Id == sr.getId()){
							ic.Sucesso = true;
						}
					}
				} 
			} 
			lstProcesso.clear();
		} catch (Exception ex){
			ApexPages.addMessages(ex);
			throw new CustomException ('Erro ao gravar registro(s): ' + ex.getMessage() + ' na linha: ' + ex.getLineNumber() + ' - ' + upResult);
		}
		return page;
	}
	/*
		public void Add(){
			count = count + 1;
			addMoreRows();
		}

		private void addMoreRows(){
			innerClass objInnerClass = new innerClass(count);
			lstInner.add(objInnerClass);
		}
 	*/
	public void Del(){

		
		Processo__c empty = new Processo__c();

		try {

			Integer toDel = Integer.valueOf(selectedRowIndex) -2 ;
 
			if (lstInner[toDel].processo == empty){
			
				lstInner.remove(toDel);
				count = count - 1;
			
			} else {

				Processo__c processoDel = lstInner[toDel].processo;

				Database.DeleteResult dbDel = Database.delete ( processoDel ) ;
				
				if (dbDel.isSuccess()){
					lstInner.remove(toDel);
					count = count - 1;		
					/*if (count == 0){
						Add();		
					}
					*/	
				}
			}

		} catch (Exception ex){
			ApexPages.addMessages(ex);
			throw new CustomException ('Erro ao excluir registro: ' + ex.getMessage() + ' na linha: ' + ex.getLineNumber());
		}
		
	}

	public PlanilhaDeTempoController(ApexPages.StandardController controller){
		lstInner = new List<innerClass>();
		//addMoreRows(); 
		selectedRowIndex = '0';
	}

	public void Add(){
		count = count + 1;
		addMoreRows(this.selectedChamadoId);
	}

	private void addMoreRows(String id){
		innerClass objInnerClass = new innerClass(count, id);
		lstInner.add(objInnerClass);
	}

	public class innerClass{

		public String recCount{get;set;}
		public Processo__c processo {get;set;}
		public Boolean Sucesso {get;set;}
		
		public innerClass(Integer intCount){
			recCount = String.valueOf(intCount);
			processo = new Processo__c();
			Sucesso = false;
		}

		public innerClass(Integer intCount, String id){
			recCount = String.valueOf(intCount);
			processo = new Processo__c();
			processo.Chamado__c = id; 
			Sucesso = false;
		}
	}
	
	public class CustomException extends Exception {
		public CustomException(String message, Integer line) {
			
			this(message);

		}
	}

	/*

		public String  selectedChamadoId {set;get;}

		public PlanilhaDeTempoController(){

		}

		public List<SelectOption> getChamado() {
			List<SelectOption> portfolioOptionList = new list<SelectOption>();
			

			portfolioOptionList.add(new SelectOption('-','-'));
			List<Chamado__c> chamados = [SELECT Id, Name, DescricaoResumida__c, Cliente__r.Name FROM Chamado__c 
										WHERE Status__c NOT IN ('Cancelado','Resolvido') AND Atribuicao__c = : userInfo.getUserId()
										ORDER BY Name];
			for ( Chamado__c chamado: chamados  ){
				portfolioOptionList.add(new SelectOption(chamado.id, chamado.Name+': '+ chamado.DescricaoResumida__c));
			
			} 
			return portfolioOptionList;
		}

		public List<Processo__c> setProcessos(Processo__c processo){
			List<Processo__c> novoProcesso = new List<Processo__c>();
			novoProcesso.add(processo);
			return novoProcesso;
		}

		public List<Processo__c> getProcessos(){
			List<Processo__c> novoProcesso = [SELECT chamado__c, Data__c, Inicio__c, Fim__c, Tempo__c, Descricao__c FROM Processo__c WHERE chamado__c = :selectedChamadoId];
			return novoProcesso;
		}

		global List<Processo__c> ListaProcessos(){ 
			List<Processo__c> novoProcesso = [SELECT chamado__c, Data__c, Inicio__c, Fim__c, Tempo__c, Descricao__c FROM Processo__c WHERE chamado__c = :selectedChamadoId];
			return novoProcesso;
		}

		
	*/
}
