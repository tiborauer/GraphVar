%  This file is part of GraphVar.
% 
%  Copyright (C) 2014
% 
%  GraphVar is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
% 
%  GraphVar is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
% 
%  You should have received a copy of the GNU General Public License
%  along with GraphVar.  If not, see <http://www.gnu.org/licenses/>.

function position = getPositionOnFigure( hObject,units )
%GETPOSITIONONFIGURE returns absolute position of object on a figure
%
% (since get(hObject,'Position') returns position relative to hObject's
%  parent)

hObject_pos=getRelPosition(hObject,units);
parent = get(hObject,'Parent');
parent_type = get(parent,'Type');

if isequal(parent_type,'figure')
    position = hObject_pos;
    return;
    
else
    parent_pos = getPositionOnFigure( parent,units );
    position = relativePos2absolutePos(hObject_pos,parent_pos,units);
end

function absolute_pos = relativePos2absolutePos( relative_pos,parent_position,units )
%RELATIVEPOS2ABSOLUTEPOS returns absolute object position from it's parent
%position and it's position relative to it's parent

if strcmp(units,'normalized')
    scale=parent_position(3:4);
    absolute_pos(1:2)=  relative_pos(1:2).*scale+parent_position(1:2);
    absolute_pos(3:4)=  relative_pos(3:4).*scale;
else
    absolute_pos(1:2)=  relative_pos(1:2)+parent_position(1:2);
    absolute_pos(3:4)=  relative_pos(3:4);
end