load 'C:\Users\Lenovo\Desktop\dp_18-21_oct_2018\rows.rb'
int=S[0].bounds.intersect S[1].bounds;

b1=S[0].bounds.intersect S[1].bounds;
b2=S[0].bounds.intersect S[1].bounds;

(0..7).each{|x| corners<<intx.corner(x)}
(0..7).each{|x| face1_pts << b1.corner(x)}

def get_xn_pts c1, c2
	xn = c1.bounds.intersect c2.bounds
	corners = []
	(0..7).each{|x| corners<<xn.corner(x)}
	arr = corners.inject([]){ |array, point| array.any?{ |p| p == point } ? array : array << point }
	return arr
end

f1=DP.ents.add_face(get_xn_pts S[0], S[1])

f2=DP.ents.add_face(get_xn_pts S[0], S[1])
