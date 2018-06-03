SRC=main.d place.d rtree/rtree.d rtree/shape.d
DMDFLAGS=-w -color -O
OFNAME=main

all:
	@dmd ${DMDFLAGS} ${SRC} -of=${OFNAME}

clean:
	@rm -f ${OFNAME} *.o
