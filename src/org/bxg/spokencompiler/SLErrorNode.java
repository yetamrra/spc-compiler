/*
 * Copyright 2014 Benjamin M. Gordon
 * 
 * This file is part of the spoken language compiler.
 *
 * The spoken language compiler is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The spoken language compiler is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the spoken language compiler.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.bxg.spokencompiler;

import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.Token;
import org.antlr.runtime.TokenStream;
import org.antlr.runtime.tree.CommonErrorNode;

// The point of this class is just to make a version
// of CommonErrorNode that can be cast to SLTreeNode
public class SLErrorNode extends SLTreeNode {

    private CommonErrorNode realNode;
    
    public SLErrorNode(TokenStream input, Token start, Token stop, RecognitionException e)
    {
        super(start);
        realNode = new CommonErrorNode(input, start, stop, e);
    }
    
    @Override
    public boolean isNil() { return realNode.isNil(); }
    
    @Override
    public int getType() { return realNode.getType(); }
    
    @Override
    public String getText() { return realNode.getText(); }
    
    @Override
    public String toString() { return realNode.toString(); }
}
