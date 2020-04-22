"""empty message

Revision ID: 0157d8c777b0
Revises: e9e89949d7f3
Create Date: 2020-04-13 12:19:47.037976

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0157d8c777b0'
down_revision = 'e9e89949d7f3'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('user',
    sa.Column('uid', sa.Integer(), nullable=False),
    sa.Column('email', sa.String(length=80), nullable=False),
    sa.Column('password', sa.String(length=120), nullable=False),
    sa.Column('curr_loc', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['curr_loc'], ['location.loc_id'], ),
    sa.PrimaryKeyConstraint('uid'),
    sa.UniqueConstraint('email')
    )
    op.create_table('user_locations',
    sa.Column('uid', sa.Integer(), nullable=False),
    sa.Column('loc_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['loc_id'], ['location.loc_id'], ),
    sa.ForeignKeyConstraint(['uid'], ['user.uid'], ),
    sa.PrimaryKeyConstraint('uid', 'loc_id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('user_locations')
    op.drop_table('user')
    # ### end Alembic commands ###