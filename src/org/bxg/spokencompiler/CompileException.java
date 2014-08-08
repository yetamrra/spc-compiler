/*
 * Copyright 2012-2014 Benjamin M. Gordon
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

public class CompileException extends RuntimeException
{
	private int line = 0;

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public CompileException( String message )
	{
		super( message );
	}

	public CompileException( String message, int line )
	{
		super( message );
		this.line = line;
	}

	public int getLine()
	{
		return line;
	}
};
