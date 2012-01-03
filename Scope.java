public interface Scope {
    public String getScopeName();
    public Scope getParentScope();
    public void define(SymEntry sym);
    public SymEntry resolve(String name, boolean localOnly);
}
