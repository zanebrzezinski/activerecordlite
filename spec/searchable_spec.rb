require 'sql_object'
require 'db_connection'
require 'searchable'
require 'db_info'
require 'associatable'
require 'securerandom'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Player < SQLObject
      finalize!
    end

    class Manager < SQLObject
      self.table_name = 'managers'

      finalize!
    end
  end

  it '#where searches with single criterion' do
    players = Player.where(name: 'Degrom')
    player = players.first

    expect(players.length).to eq(1)
    expect(player.name).to eq('Degrom')
  end

  it '#where can return multiple objects' do
    managers = Manager.where(team_id: 1)
    expect(managers.length).to eq(2)
  end

  it '#where searches with multiple criteria' do
    managers = Manager.where(fname: 'Joe', team_id: 2)
    expect(managers.length).to eq(1)

    manager = managers[0]
    expect(manager.fname).to eq('Joe')
    expect(manager.team_id).to eq(2)
  end

  it '#where returns [] if nothing matches the criteria' do
    expect(Manager.where(fname: 'Nowhere', lname: 'Man')).to eq([])
  end
end
