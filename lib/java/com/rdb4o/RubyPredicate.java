package com.rdb4o;

import com.db4o.query.*;

public abstract class RubyPredicate extends com.db4o.query.Predicate<Rdb4oBase> {
    public boolean match(Rdb4oBase obj) {
        //System.out.println("sprawdzam..");
        //return true;
        return rubyMatch(obj);
    }

    public abstract boolean rubyMatch(Rdb4oBase obj);
}
