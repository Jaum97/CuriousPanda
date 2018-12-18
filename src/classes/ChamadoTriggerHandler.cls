public class ChamadoTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        
    }
    public override void afterInsert() {
    	List<Chamado__c> chamados = (List<Chamado__c>) Trigger.new;
    	new ChamadoBusinessNovo().enviaConfirmacaoNovoChamado(chamados);
    }
}